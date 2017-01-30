require 'rails_helper'

RSpec.describe CatalogController do
  context "with mvw", vcr: { cassette_name: 'mvw' } do
    let(:url) { "https://hydra-dev.princeton.edu/concern/multi_volume_works/f4752g76q/manifest" }
    it "hides scanned resources with parents" do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = IIIFResource.new url: url, exhibit: exhibit
      expect(resource.save_and_index).to be_truthy

      get :index, params: { q: "", exhibit_id: exhibit.id }

      expect(document_ids).to eq [resource.document_builder.to_solr.to_a.first[:id]]
    end
    it "returns MVW from metadata found in volume" do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = IIIFResource.new url: url, exhibit: exhibit
      expect(resource.save_and_index).to be_truthy

      get :index, params: { q: "Scanned Resource", exhibit_id: exhibit.id }

      expect(document_ids).to eq [resource.document_builder.to_solr.to_a.first[:id]]
    end
  end
  it "can search across, and hides duplicates" do
    index.add(id: "1",
              "#{Spotlight::Resources::Iiif::Engine.config.iiif_manifest_field}": "manifest",
              full_title_ssim: ["Test"],
              spotlight_resource_type_ssim: ["iiif_resources"])
    index.add(id: "2",
              "#{Spotlight::Resources::Iiif::Engine.config.iiif_manifest_field}": "manifest",
              full_title_ssim: ["Test"],
              spotlight_resource_type_ssim: ["iiif_resources"])
    index.commit

    get :index, params: { search_field: "all_fields" }

    expect(document_ids.length).to eq 1
    expect(assigns[:response][:response][:numFound]).to eq 1
    expect(assigns[:response]["facet_counts"]["facet_fields"]).to eq("readonly_language_ssim" => [], "readonly_subject_ssim" => [])
  end

  def document_ids
    assigns[:document_list].map do |x|
      x["id"]
    end
  end

  def index
    Blacklight.default_index.connection
  end
end
