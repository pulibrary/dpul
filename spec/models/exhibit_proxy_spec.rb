# frozen_string_literal: true

require "rails_helper"

describe ExhibitProxy do
  with_queue_adapter :inline
  describe "#document_builder" do
    subject(:exhibit_proxy) { described_class.new(exhibit) }

    let(:exhibit) { instance_double(Spotlight::Exhibit) }
    let(:collection_manifest) { double }

    before do
      allow(exhibit).to receive(:slug).and_return("test-exhibit")
      allow(collection_manifest).to receive(:manifests).and_return([{ "@id" => "uri://to-manifest1" }])
      allow(CollectionManifest).to receive(:find_by_slug).and_return(collection_manifest)
    end

    it "constructs a DummyDocumentBuilder using the members in the Manifest" do
      expect(exhibit_proxy.document_builder).to be_a ExhibitProxy::DummyDocumentBuilder
      expect(exhibit_proxy.document_builder.members).to eq ["uri://to-manifest1"]
      expect(exhibit_proxy.document_builder.documents_to_index).to eq ["uri://to-manifest1"]
    end
  end

  describe "#reindex" do
    context "when a resource is no longer in the manifest" do
      # rubocop:disable Style/BracesAroundHashParameters
      before do
        stub_collections(fixture: "collections.json")
        url = "https://hydra-dev.princeton.edu/collections/2b88qc199/manifest"
        fixture1 = "2b88qc199.json"
        fixture2 = "2b88qc199-item-deleted.json"
        body1 = File.read(Rails.root.join("spec", "fixtures", "manifests", fixture1))
        body2 = File.read(Rails.root.join("spec", "fixtures", "manifests", fixture2))
        headers = { "content-type" => "application/ld+json" }
        stub_request(:get, url)
          .to_return(
            { status: 200, body: body1, headers: },
            { status: 200, body: body2, headers: }
          )
        stub_manifest(url: "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest", fixture: "1r66j1149.json")
        stub_metadata(id: "1234567")
        stub_manifest(url: "https://hydra-dev.princeton.edu/concern/scanned_resources/44558d29f/manifest", fixture: "44558d29f.json")
      end
      # rubocop:enable Style/BracesAroundHashParameters

      it "deletes the resource from solr but not from the database" do
        exhibit = FactoryBot.create(:exhibit, slug: "princeton-best")

        # first index will use the manifest with 2 items
        described_class.new(exhibit).reindex
        Blacklight.default_index.connection.commit
        expect(IiifResource.all.count).to eq 2
        expect(Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["numFound"]).to eq 2

        # second index uses the manifest with 1 item
        described_class.new(exhibit).reindex
        Blacklight.default_index.connection.commit
        expect(IiifResource.all.count).to eq 2
        response = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]
        expect(response["numFound"]).to eq 1
        expect(response["docs"].first["content_metadata_iiif_manifest_field_ssi"]).to eq "https://hydra-dev.princeton.edu/concern/scanned_resources/44558d29f/manifest"
      end
    end

    context "when a resource was persisted with a token in its url" do
      before do
        stub_collections(fixture: "collections.json")
        body = File.read(Rails.root.join("spec", "fixtures", "manifests", "2b88qc199.json"))
        headers = { "content-type" => "application/ld+json" }
        stub_request(:get, "https://hydra-dev.princeton.edu/collections/2b88qc199/manifest")
          .to_return(
            status: 200, body:, headers:
          )
        stub_manifest(url: "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest", fixture: "1r66j1149.json")
        stub_manifest(url: "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest?auth_token=12345", fixture: "1r66j1149.json")
        stub_metadata(id: "1234567")
        stub_manifest(url: "https://hydra-dev.princeton.edu/concern/scanned_resources/44558d29f/manifest", fixture: "44558d29f.json")
      end

      it "does not delete it before reindexing" do
        exhibit = FactoryBot.create(:exhibit, slug: "princeton-best")

        # first get them in the index
        described_class.new(exhibit).reindex
        Blacklight.default_index.connection.commit
        expect(IiifResource.all.count).to eq 2
        expect(Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["numFound"]).to eq 2

        resource = IiifResource.first
        resource.url = "#{resource.url}?auth_token=12345"
        resource.save
        allow(resource).to receive(:remove_from_solr)

        expect(described_class.new(exhibit).members_to_remove_from_index).to be_empty
      end
    end
  end
end
