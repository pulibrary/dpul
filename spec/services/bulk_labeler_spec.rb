# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkLabeler do
  subject(:labeler) { described_class }

  let(:url) { "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest" }

  before do
    stub_manifest(url: url, fixture: "1r66j1149.json")
    stub_metadata(id: "1234567")
  end

  context "when the resource is updated" do
    it "overrides the title" do
      exhibit = FactoryBot.create(:exhibit, slug: "first")
      r = IIIFResource.new(url: url, exhibit: exhibit)
      r.save_and_index
      Blacklight.default_index.connection.commit

      labeler.run(exhibit: exhibit, id: r.id, title: "override title", description: "foo")

      sidecar = r.solr_document_sidecars.select { |sc| sc.data["readonly_collections_ssim"] }.first
      expect(sidecar.data["override-title_ssim"]).to eq("override title")
    end
  end
end
