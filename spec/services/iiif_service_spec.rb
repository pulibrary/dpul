# frozen_string_literal: true

require 'rails_helper'

describe IiifService do
  describe '.iiif_response' do
    subject(:response) { described_class.iiif_response(url) }

    let(:url) { 'http://to-manifest1' }
    let(:http_response) { instance_double(Faraday::Response) }
    let(:http_client) { instance_double(Faraday::Connection) }
    let(:logger) { instance_double(ActiveSupport::Logger) }
    let(:manifest_fixture) { test_manifest1 }

    before do
      WebMock.disable!

      allow(http_response).to receive(:success?).and_return(true)
      # Return the default fixture as the remotely referenced JSON-LD expression
      allow(http_response).to receive(:body).and_return(manifest_fixture)
      allow(Spotlight::Resources::IiifService).to receive(:http_client).and_return(http_client)
      allow(http_client).to receive(:get).and_return(http_response)
    end

    after do
      WebMock.enable!
    end

    it 'retrieves the Manifest from the IIIF service' do
      expect(response).not_to be_empty
      expect { JSON.parse(response) }.not_to raise_error
      values = JSON.parse(response)
      expect(values['label']).to eq 'Test Manifest 1'
    end

    context 'when the request is unsuccessful' do
      before do
        allow(http_response).to receive(:success?).and_return(false)
        allow(logger).to receive(:info)
        allow(Rails).to receive(:logger).and_return(logger)
      end

      it 'returns empty values and logs the error' do
        expect(response).to eq "{}"
        expect(logger).to have_received(:info).with("Failed to get #{url}")
      end
    end

    context 'when the request times out' do
      before do
        allow(http_client).to receive(:get).and_raise(Faraday::TimeoutError)
        allow(logger).to receive(:warn)
        allow(Rails).to receive(:logger).and_return(logger)
      end

      it 'returns empty values and logs the error as warning' do
        expect(response).to eq "{}"
        expect(logger).to have_received(:warn).with("HTTP GET for #{url} failed with timeout")
      end
    end

    context 'when an auth token is set' do
      before do
        allow(Pomegranate).to receive(:config).and_return({ "manifest_authorization_token" => "token" })
      end

      it 'appends the token to the request' do
        expect(response).not_to be_empty
        authorized_url = url + "?auth_token=token"
        expect(http_client).to have_received(:get).with(authorized_url)
      end

      context 'with a url that already has a token' do
        let(:url) { 'http://to-manifest1?auth_token=token' }

        it 'does not append a new auth_token' do
          expect(response).not_to be_empty
          expect(http_client).to have_received(:get).with(url)
        end
      end
    end
  end
end
