require 'rails_helper'

RSpec.describe PlumEventProcessor, vcr: { cassette_name: "plum_events", allow_playback_repeats: true } do
  subject { described_class.new(event) }
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
      expect(subject.process).to eq false
    end
  end
  context "when given a creation event" do
    let(:type) { "CREATED" }
    it "builds the resource in that exhibit" do
      exhibit = FactoryGirl.create(:exhibit, slug: "first")

      expect(subject.process).to eq true

      expect(IIIFResource.where(exhibit: exhibit, url: url).length).to eq 1
    end
  end
  context "when given a delete event" do
    let(:type) { "DELETED" }
    it "deletes that resource" do
      exhibit = FactoryGirl.create(:exhibit, slug: "first")
      IIIFResource.new(manifest_url: url, exhibit: exhibit).save_and_index

      expect(subject.process).to eq true

      expect(IIIFResource.all.length).to eq 0
      expect(Blacklight.default_index.connection.get("select")["response"]["docs"].length).to eq 0
    end
  end
  context "when given an update event" do
    let(:type) { "UPDATED" }
    it "updates that resource" do
      exhibit = FactoryGirl.create(:exhibit, slug: "first")
      IIIFResource.new(manifest_url: url, exhibit: exhibit).save_and_index

      expect(subject.process).to eq true
      resource = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"].first

      expect(resource["full_title_ssim"]).to eq ["Updated Record"]
    end
    context "when it's removed from a collection" do
      let(:collection_slugs) { [] }
      it "removes old ones" do
        exhibit = FactoryGirl.create(:exhibit, slug: "first")
        IIIFResource.new(manifest_url: url, exhibit: exhibit).save_and_index

        expect(subject.process).to eq true

        expect(IIIFResource.all.length).to eq 0
        expect(Blacklight.default_index.connection.get("select")["response"]["docs"].length).to eq 0
      end
    end
    context "when it's added to a new exhibit" do
      let(:collection_slugs) { ["banana"] }
      it "moves it to a new one" do
        exhibit = FactoryGirl.create(:exhibit, slug: "first")
        FactoryGirl.create(:exhibit, slug: "banana")
        IIIFResource.new(manifest_url: url, exhibit: exhibit).save_and_index

        expect(subject.process).to eq true

        expect(IIIFResource.joins(:exhibit).where("spotlight_exhibits.slug" => "banana").length).to eq 1
        expect(Blacklight.default_index.connection.get("select")["response"]["docs"].length).to eq 1
      end
    end
  end
end
