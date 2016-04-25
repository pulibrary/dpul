require 'rails_helper'

RSpec.describe CatalogController do
  context "with mvw", vcr: { cassette_name: 'mvw' } do
    let(:url) { "https://hydra-dev.princeton.edu/concern/multi_volume_works/f4752g76q/manifest" }
    it "hides scanned resources with parents" do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = IIIFResource.new manifest_url: url, exhibit: exhibit
      expect(resource.save_and_index).to be_truthy

      get :index, q: "", exhibit_id: exhibit.id

      expect(document_ids).to eq [resource.to_solr.to_a.first[:id]]
    end
    it "returns MVW from metadata found in volume" do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = IIIFResource.new manifest_url: url, exhibit: exhibit
      expect(resource.save_and_index).to be_truthy

      get :index, q: "SR1", exhibit_id: exhibit.id

      expect(document_ids).to eq [resource.to_solr.to_a.first[:id]]
    end
  end

  def document_ids
    assigns[:document_list].map do |x|
      x["id"]
    end
  end
end
