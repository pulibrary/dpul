require 'rails_helper'

RSpec.describe IiifManifest do
  let(:manifest_service) { described_class.new(url: url, manifest: manifest, collection: collection) }
  let(:url) { 'uri://some_id/manifest' }
  let(:collection) { instance_double(Spotlight::Resources::IiifManifest) }
  let(:manifest_fixture) { test_manifest1 }
  before do
    allow(collection).to receive(:compound_id).and_return('1')
    stub_iiif_response_for_url(url, manifest_fixture)
    manifest_service.with_exhibit(exhibit)
  end

  describe '#to_solr' do
    let(:manifest) { IiifService.new(url).send(:object) }
    let(:exhibit) { FactoryBot.create(:exhibit) }
    describe 'sort_title' do
      it 'is a single-value text field' do
        expect(manifest_service.to_solr["sort_title_ssi"]).to eq "Test Manifest 1"
      end
    end

    describe 'sort_date' do
      it 'is a single-value text field' do
        expect(manifest_service.to_solr["sort_date_ssi"]).to eq "1929"
      end
    end

    describe 'sort_author' do
      it 'is a single-value text field' do
        expect(manifest_service.to_solr["sort_author_ssi"]).to eq "John Doe"
      end
    end
  end
end
