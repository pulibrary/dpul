# frozen_string_literal: true

require "rails_helper"

RSpec.describe UniversalViewer do
  subject(:universal_viewer) { described_class.new(url, **params) }

  let(:url) { "https://institution.edu/viewer" }
  let(:params) do
    {
      manifest: "https://images.institution.edu/resource1/manifest",
      config: "https://institution.edu/viewer/config"
    }
  end

  describe "#url" do
    it "generates the URL for an embedded Universal Viewer installation" do
      expect(universal_viewer.url).to eq "https://institution.edu/viewer#?manifest=https%3A%2F%2Fimages.institution.edu%2Fresource1%2Fmanifest&config=https%3A%2F%2Finstitution.edu%2Fviewer%2Fconfig"
    end
  end
end
