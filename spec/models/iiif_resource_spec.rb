require 'rails_helper'

describe IIIFResource do
  context 'with recorded http interactions', vcr: { cassette_name: 'all_collections' } do
    let(:url) { 'https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest' }
    it 'ingests a iiif manifest' do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      expect(resource.save).to be true

      solr_doc = nil
      resource.document_builder.to_solr { |x| solr_doc = x }
      expect(solr_doc["full_title_tesim"]).to eq 'Christopher and his kind, 1929-1939'
      expect(solr_doc["readonly_created_tesim"]).to eq ["1976-01-01T00:00:00Z"]
      expect(solr_doc["readonly_range-label_tesim"]).to eq ["Chapter 1", "Chapter 2"]
    end
    context "when given a MVW", vcr: { cassette_name: 'mvw' } do
      let(:url) { "https://hydra-dev.princeton.edu/concern/multi_volume_works/f4752g76q/manifest" }
      it "ingests both items as individual solr records, marking the child" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
        resource = described_class.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy

        docs = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"]
        expect(docs.length).to eq 2
        scanned_resource_doc = docs.find { |x| x["full_title_tesim"] == ["Scanned Resource 1"] }
        mvw_doc = docs.find { |x| x["full_title_tesim"] == ["MVW"] }
        expect(scanned_resource_doc["collection_id_ssim"]).to eq [mvw_doc["id"]]
        expect(mvw_doc["collection_id_ssim"]).to eq nil
      end
      it "stores the correct full image URL" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
        resource = described_class.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy

        docs = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"]
        scanned_resource_doc = docs.find { |x| x["full_title_tesim"] == ["Scanned Resource 1"] }
        expect(scanned_resource_doc["full_image_url_ssm"]).to eq ["https://libimages1.princeton.edu/loris/plum/hq%2F37%2Fvn%2F61%2F6-intermediate_file.jp2/full/!600,600/0/default.jpg"]
      end
    end
    context "when given an unreachable seeAlso url", vcr: { cassette_name: 'see_also_connection_failed' } do
      let(:url) { "https://hydra-dev.princeton.edu/concern/scanned_resources/s9w032300r/manifest" }
      it "ingests a iiif manifest using the metadata pool, excludes range labels when missing" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
        resource = described_class.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy
        docs = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"]
        scanned_resource_doc = docs.find { |x| x["full_title_tesim"] == ["Christopher and his kind, 1929-1939"] }
        expect(scanned_resource_doc["readonly_date-created_tesim"]).to eq ['1976-01-01T00:00:00Z']
        expect(scanned_resource_doc["readonly_range-label_tesim"]).to eq nil
        expect(scanned_resource_doc["readonly_language_tesim"]).to eq ["English"]
      end
    end
  end
end
