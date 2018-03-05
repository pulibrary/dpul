require 'rails_helper'

RSpec.describe CatalogController do
  let(:user) { nil }
  context "with mvw", vcr: { cassette_name: 'mvw' } do
    let(:url) { "https://hydra-dev.princeton.edu/concern/multi_volume_works/f4752g76q/manifest" }
    it "hides scanned resources with parents" do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true
      resource = IIIFResource.new url: url, exhibit: exhibit
      expect(resource.save_and_index).to be_truthy

      get :index, params: { q: "", exhibit_id: exhibit.id }

      expect(document_ids).to eq [resource.document_builder.to_solr.to_a.first[:id]]
    end
    context "when not signed in" do
      it "hides resources which are in un-published exhibits" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: false
        resource = IIIFResource.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy

        get :index, params: { q: "", exhibit_id: exhibit.id }

        expect(document_ids).to eq []
      end
      it "hides private resources in published exhibits" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true
        resource = IIIFResource.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy
        document = SolrDocument.find(resource.noid, exhibit: resource.exhibit)
        document.make_private!(resource.exhibit)
        document.save
        Blacklight.default_index.connection.commit

        get :index, params: { q: "", exhibit_id: exhibit.id }

        expect(document_ids).to eq []
      end
    end
    context "when signed in as a site admin" do
      let(:user) { FactoryBot.create(:site_admin) }
      it "doesn't hide resources from un-published exhibits" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: false
        resource = IIIFResource.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy
        sign_in user

        get :index, params: { q: "", exhibit_id: exhibit.id }

        expect(document_ids).not_to be_empty
      end
      it "doesn't hide private resources in public exhibits" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true
        resource = IIIFResource.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy
        document = SolrDocument.find(resource.noid, exhibit: resource.exhibit)
        document.make_private!(resource.exhibit)
        document.save
        Blacklight.default_index.connection.commit
        sign_in user

        get :index, params: { q: "", exhibit_id: exhibit.id }

        expect(document_ids).not_to be_empty
      end
      it "permits queries with quotes" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true
        document = SolrDocument.new(id: 'd279a557a62937a8895eebbca2d4744c', exhibit: exhibit)
        Spotlight::SolrDocumentSidecar.create!(
          document: document, exhibit: exhibit,
          data: { 'full_title_tesim' => ['"title1"'] }
        )

        document.make_private!(exhibit)
        document.save
        Blacklight.default_index.connection.commit
        sign_in user

        get :index, params: { q: '"title1"', exhibit_id: exhibit.id }

        expect(document_ids).not_to be_empty
      end
    end
    it "returns MVW from metadata found in volume" do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true
      resource = IIIFResource.new url: url, exhibit: exhibit
      expect(resource.save_and_index).to be_truthy

      get :index, params: { q: "Scanned Resource", exhibit_id: exhibit.id }

      expect(document_ids).to eq [resource.document_builder.to_solr.to_a.first[:id]]
    end
  end
  it "can search across, and hides duplicates" do
    index.add(id: "1",
              "#{Spotlight::Engine.config.iiif_manifest_field}": "manifest",
              full_title_ssim: ["Test"],
              spotlight_resource_type_ssim: ["iiif_resources"])
    index.add(id: "2",
              "#{Spotlight::Engine.config.iiif_manifest_field}": "manifest",
              full_title_ssim: ["Test"],
              spotlight_resource_type_ssim: ["iiif_resources"])
    index.commit

    get :index, params: { search_field: "all_fields" }

    expect(document_ids.length).to eq 1
    expect(assigns[:response][:response][:numFound]).to eq 1
    expect(assigns[:response]["facet_counts"]["facet_fields"]).to eq("readonly_language_ssim" => [], "readonly_subject_ssim" => [])
  end
  it "can get a single record by its access identifier" do
    index.add(id: "1",
              access_identifier_ssim: "123")
    index.commit

    get :show, params: { id: "123" }

    expect(assigns[:document].id).to eq "1"
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
