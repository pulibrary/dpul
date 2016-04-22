require 'rails_helper'

describe IIIFResource do
  context 'with recorded http interactions', vcr: { cassette_name: 'all_collections', record: :new_episodes } do
    let(:url) { 'https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest' }
    it 'ingests a iiif manifest' do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new manifest_url: url, exhibit: exhibit
      expect(resource.save).to be true

      solr_doc = nil
      resource.to_solr { |x| solr_doc = x }
      expect(solr_doc["full_title_ssim"]).to eq 'Christopher and his kind, 1929-1939'
      expect(solr_doc["date-created_tesim"]).to eq ['1976', '2010']
    end
    context "when given a MVW", vcr: { cassette_name: 'mvw' } do
      let(:url) { "https://hydra-dev.princeton.edu/concern/multi_volume_works/f4752g76q/manifest" }
      it "ingests both items as individual solr records, marking the child" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
        resource = described_class.new manifest_url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy

        docs = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"]
        expect(docs.length).to eq 2
        scanned_resource_doc = docs.find { |x| x["full_title_ssim"] == ["SR1"] }
        mvw_doc = docs.find { |x| x["full_title_ssim"] == ["MVW"] }
        expect(scanned_resource_doc["collection_id_ssim"]).to eq [mvw_doc["id"]]
        expect(mvw_doc["collection_id_ssim"]).to eq nil
      end
    end
  end
end
