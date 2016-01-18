require 'rails_helper'

RSpec.describe ExternalManifest, vcr: { cassette_name: "all_collections" } do
  describe ".load" do
    subject { described_class.load(manifest_url) }
    let(:manifest_url) { "https://hydra-dev.princeton.edu/collections/manifest" }
    it "loads up a manifest" do
      expect(subject.collections.length).to eql 2
    end
  end
end
