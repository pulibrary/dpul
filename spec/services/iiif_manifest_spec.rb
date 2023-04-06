# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IiifManifest do
  let(:manifest_service) { described_class.new(url:, manifest:, collection:) }
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

      after do
        WebMock.enable!
      end

      it 'populates the metadata with the remote values' do
        expect(manifest_service.to_solr['sort_title_ssi']).to eq "Test Manifest 1"
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

    describe 'full_image_url' do
      it 'is a single-value text field' do
        expect(manifest_service.to_solr[:full_image_url_ssm]).to eq "uri://to-thumbnail/full/!800,800/0/default.jpg"
      end
    end

    describe 'range-label' do
      it 'is a multi-value text field' do
        expect(manifest_service.to_solr["readonly_range-label_tesim"]).to eq ["range label value"]
      end
    end

    describe 'multi-volume work manifest' do
      let(:manifest_fixture) { test_manifest_mvw }
      let(:member_manifest_fixture) { test_manifest1 }

      before do
        stub_iiif_response_for_url("uri://for-manifest1/manifest", member_manifest_fixture)
      end

      it 'has the correct image urls' do
        expect(manifest_service.to_solr[:tile_source_ssim]).to eq ["uri://to-image-service/info.json"]
      end

      context 'when an auth token is specified' do
        it 'appends the token to the request' do
          stub_iiif_response_for_url("uri://for-manifest1/manifest?auth_token=token", member_manifest_fixture)
          allow(Pomegranate).to receive(:config).and_return({ "manifest_authorization_token" => "token" })
          expect(manifest_service.to_solr[:tile_source_ssim]).to eq ["uri://to-image-service/info.json"]
        end
      end
    end

    context 'without a url or manifest' do
      let(:manifest_service) { described_class.new(url: nil, manifest: nil, collection:) }
      it 'returns an empty hash' do
        expect(manifest_service.to_solr[:tile_source_ssim]).to be_nil
      end
    end
  end
end
