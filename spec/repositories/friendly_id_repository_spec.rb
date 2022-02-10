# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyIdRepository do
  let(:repository) { described_class.new(CatalogController.new.blacklight_config) }
  let(:url) { 'https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest' }
  let(:exhibit) { Spotlight::Exhibit.create title: 'Exhibit A' }
  let(:resource) { IIIFResource.create(url: url, exhibit: exhibit) }
  before do
    stub_manifest(url: url, fixture: "1r66j1149.json")
    stub_metadata(id: "1234567")
  end

  describe "#find" do
    let(:manifest) do
      resource.iiif_manifests.first.tap do |man|
        man.with_exhibit(exhibit)
      end
    end
    before do
      resource.reindex
      Blacklight.default_index.connection.commit
    end

    context "when an exhibit isn't passed" do
      it "finds the record by searching inside the access_identifier field" do
        output = repository.find(manifest.noid)
        expect(output["response"]["docs"].first["id"]).to eq manifest.compound_id
      end
    end

    context 'when an exhibit is not passed and no documents can be found' do
      it 'attempts to retrieve it using the default ID and raises an error' do
        expect { repository.find("test-id") }.to raise_error(Blacklight::Exceptions::RecordNotFound)
      end
    end

    context "when an exhibit is passed" do
      it "generates a compound id" do
        allow(repository).to receive(:search)
        allow(repository.blacklight_config).to receive(:current_exhibit).and_return(exhibit)
        output = repository.find(manifest.noid)
        expect(output["response"]["docs"].first["id"]).to eq manifest.compound_id
        expect(repository).not_to have_received(:search)
      end
    end
  end
end
