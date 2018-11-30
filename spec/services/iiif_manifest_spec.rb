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

  context 'with a Manifest referencing another resource' do
    let(:manifest_fixture) { test_manifest_see_also }

    describe '#to_solr' do
      let(:manifest) { IiifService.new(url).send(:object) }
      let(:exhibit) { FactoryBot.create(:exhibit) }
      let(:response) { instance_double(Faraday::Response) }

      before do
        WebMock.disable!

        allow(response).to receive(:status).and_return(200)
        # Return the default fixture as the remotely referenced JSON-LD expression
        allow(response).to receive(:body).and_return(test_manifest1)
        allow(Faraday).to receive(:get).and_return(response)
      end

      it 'populates the metadata with the remote values' do
        expect(manifest_service.to_solr['sort_title_ssi']).to eq "Test Manifest 1"
      end

      after do
        WebMock.enable!
      end
    end
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
    describe 'range-label' do
      it 'is a multi-value text field' do
        expect(manifest_service.to_solr["readonly_range-label_tesim"]).to eq ["range label value"]
      end
    end
  end
end
