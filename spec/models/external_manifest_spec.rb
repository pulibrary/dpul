# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalManifest do
  before do
    stub_collections(fixture: "collections.json")
  end

  describe ".load" do
    subject(:manifest) { described_class.load(manifest_url) }
    let(:manifest_url) { "https://hydra-dev.princeton.edu/iiif/collections" }
    it "loads up a manifest" do
      expect(manifest.collections.length).to be 2
    end
  end
end
