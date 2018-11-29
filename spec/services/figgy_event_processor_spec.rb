require 'rails_helper'

RSpec.describe FiggyEventProcessor, vcr: { cassette_name: "figgy_events", allow_playback_repeats: true } do
  subject(:processor) { described_class.new(event) }
  let(:event) do
    {
      "id" => "1r66j1149",
      "event" => type,
      "manifest_url" => url,
      "collection_slugs" => collection_slugs
    }
  end
  let(:collection_slugs) { ["first"] }
  let(:url) { "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest" }
  context "when given an unknown event" do
    let(:type) { "AWFULBADTHINGSHAPPENED" }
    it "returns false" do
      expect(processor.process).to eq false
    end
  end
  context "when given a creation event" do
    let(:type) { "CREATED" }
    it "builds the resource in that exhibit" do
      exhibit = FactoryBot.create(:exhibit, slug: "first")

      expect(processor.process).to eq true

      expect(IIIFResource.where(exhibit: exhibit, url: url).length).to eq 1
    end
  end
  context "when given a delete event" do
    let(:type) { "DELETED" }
    let(:event) do
      {
        "id" => "1r66j1149",
        "event" => "DELETED",
        "manifest_url" => "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest"
      }
    end
    it "deletes that resource" do
      exhibit = FactoryBot.create(:exhibit, slug: "first")
      IIIFResource.new(url: url, exhibit: exhibit).save_and_index
      Blacklight.default_index.connection.commit

      expect(processor.process).to eq true

      expect(IIIFResource.all.length).to eq 0
      expect(Blacklight.default_index.connection.get("select")["response"]["docs"].length).to eq 0
    end
  end
  context "when given an update event" do
    let(:type) { "UPDATED" }
    it "updates that resource" do
      exhibit = FactoryBot.create(:exhibit, slug: "first")
      IIIFResource.new(url: url, exhibit: exhibit).save_and_index

      expect(processor.process).to eq true
      Blacklight.default_index.connection.commit
      resource = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"].first

      expect(resource["full_title_tesim"]).to eq ["Updated Record"]
    end
    context "when the record is gone" do
      it "doesn't blow up" do
        exhibit = FactoryBot.create(:exhibit, slug: "first")
        IIIFResource.new(url: url, exhibit: exhibit).save_and_index
        Blacklight.default_index.connection.delete_by_query("*:*")
        Blacklight.default_index.connection.commit

        expect(processor.process).to eq true
      end
    end
    context "when the exhibit is gone" do
      it "doesn't blow up" do
        exhibit = FactoryBot.create(:exhibit, slug: "first")
        IIIFResource.new(url: url, exhibit: exhibit).save_and_index
        exhibit.delete

        expect(processor.process).to eq true
      end
    end
    context "when it's no longer accessible" do
      it "marks it as non-public" do
        exhibit = FactoryBot.create(:exhibit, slug: "first")
        IIIFResource.new(url: url, exhibit: exhibit).save_and_index

        # swap casseette to make the resource inaccessible
        VCR.use_cassette('figgy_events_no_permission') do
          expect(processor.process).to eq true
          Blacklight.default_index.connection.commit
          resource = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"].first
          expect(resource["exhibit_first_public_bsi"]).to eq false
        end
      end
    end
    context "when it's private and then is made accessible" do
      it "marks it as public" do
        exhibit = FactoryBot.create(:exhibit, slug: "first")
        IIIFResource.new(url: url, exhibit: exhibit).save_and_index
        Blacklight.default_index.connection.commit
        resource_id = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"].first["access_identifier_ssim"].first
        document = SolrDocument.find(resource_id)
        document.make_private!(exhibit)
        document.save
        Blacklight.default_index.connection.commit

        expect(processor.process).to eq true
        Blacklight.default_index.connection.commit

        resource = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"].first
        expect(resource["exhibit_first_public_bsi"]).to eq true
      end
    end
    context "when it's removed from a collection" do
      let(:collection_slugs) { [] }
      it "removes old ones" do
        exhibit = FactoryBot.create(:exhibit, slug: "first")
        IIIFResource.new(url: url, exhibit: exhibit).save_and_index

        expect(processor.process).to eq true

        expect(IIIFResource.all.length).to eq 0
        expect(Blacklight.default_index.connection.get("select")["response"]["docs"].length).to eq 0
      end
    end
    context "when it's added to a new exhibit" do
      let(:collection_slugs) { ["banana"] }
      it "moves it to a new one" do
        exhibit = FactoryBot.create(:exhibit, slug: "first")
        FactoryBot.create(:exhibit, slug: "banana")
        IIIFResource.new(url: url, exhibit: exhibit).save_and_index

        expect(processor.process).to eq true
        Blacklight.default_index.connection.commit

        expect(IIIFResource.joins(:exhibit).where("spotlight_exhibits.slug" => "banana").length).to eq 1
        expect(Blacklight.default_index.connection.get("select")["response"]["docs"].length).to eq 1
      end
    end
  end
end
