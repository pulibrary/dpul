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
  end
end
