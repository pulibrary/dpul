# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController do
  with_queue_adapter :inline
  let(:user) { nil }
  context "with full-text search" do
    let(:user) { FactoryBot.create(:site_admin) }
    it "searches" do
      url = 'https://figgy.princeton.edu/concern/ephemera_folders/e41da87f-84af-4f50-ab69-781576cf82db/manifest'
      stub_manifest(url:, fixture: 'full_text_manifest.json')
      stub_metadata(id: "e41da87f-84af-4f50-ab69-781576cf82db")
      stub_ocr_content(id: "e41da87f-84af-4f50-ab69-781576cf82db", text: "More searchable text")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true
      resource = IiifResource.new(url:, exhibit:)
      resource.save_and_index
      Blacklight.default_index.connection.commit

      get :index, params: { q: "More searchable text", exhibit_id: exhibit.id }

      expect(document_ids.length).to eq 1
      expect(controller.blacklight_config.view.keys).not_to include :embed
    end
  end

  context "with mvw" do
    let(:url) { "https://hydra-dev.princeton.edu/concern/multi_volume_works/f4752g76q/manifest" }
    before do
      stub_manifest(url:, fixture: "mvw.json")
      stub_manifest(
        url: "https://hydra-dev.princeton.edu/concern/scanned_resources/k35694439/manifest",
        fixture: "vol1.json"
      )
      stub_metadata(id: "12345678")
    end

    it "hides scanned resources with parents" do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true
      resource = IiifResource.new url: url, exhibit: exhibit
      expect(resource.save_and_index).to be_truthy
      Blacklight.default_index.connection.commit

      get :index, params: { q: "", exhibit_id: exhibit.id }

      expect(document_ids).to eq [resource.solr_documents.first[:id]]
    end
    context "when not signed in" do
      it "hides resources which are in un-published exhibits" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: false
        resource = IiifResource.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy

        get :index, params: { q: "" }

        expect(document_ids).to eq []
      end
      it "hides private resources in published exhibits" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true
        resource = IiifResource.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy
        document = SolrDocument.find(resource.noid, exhibit: resource.exhibit)
        document.make_private!(resource.exhibit)
        document.save
        Blacklight.default_index.connection.commit

        get :index, params: { q: "" }

        expect(document_ids).to eq []
      end
    end

    context "when signed in as a site admin" do
      let(:user) { FactoryBot.create(:site_admin) }
      it "doesn't hide resources from un-published exhibits" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: false
        resource = IiifResource.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy
        Blacklight.default_index.connection.commit
        sign_in user

        get :index, params: { q: "", exhibit_id: exhibit.id }

        expect(document_ids).not_to be_empty
      end
      it "doesn't hide private resources in public exhibits" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true
        resource = IiifResource.new url: url, exhibit: exhibit
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
        document = SolrDocument.new(id: 'd279a557a62937a8895eebbca2d4744c', exhibit:)
        Spotlight::SolrDocumentSidecar.create!(
          document:, exhibit:,
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
      resource = IiifResource.new url: url, exhibit: exhibit
      expect(resource.save_and_index).to be_truthy
      Blacklight.default_index.connection.commit

      get :index, params: { q: "Scanned Resource", exhibit_id: exhibit.id }

      expect(document_ids).to eq [resource.solr_documents.first[:id]]
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

    expect(assigns[:blacklight_config].view.keys).to contain_exactly :list, :atom, :rss

    expect(document_ids.length).to eq 1
    expect(assigns[:response][:response][:numFound]).to eq 1
    expect(assigns[:response]["facet_counts"]["facet_fields"]).to include "readonly_language_ssim" => []
    expect(assigns[:response]["facet_counts"]["facet_fields"]).to include "readonly_subject_ssim" => []
  end

  describe '#index' do
    before do
      index.add(
        id: '3',
        full_title_ssim: ['Item B'],
        readonly_title_ssim: ['Item B'],
        spotlight_resource_type_ssim: ['iiif_resources'],
        readonly_collections_ssim: ['Collection A', 'Collection B'],
        readonly_collections_tesim: ['Collection A', 'Collection B'],
        readonly_creator_ssim: ['Creator', 'Creator2'],
        readonly_publisher_ssim: ['Publisher'],
        readonly_format_ssim: ['Visual material']
      )
      index.commit
    end

    context "when using the JSON endpoint" do
      render_views
      it "returns all the values necessary for bento search" do
        get :index, params: { q: '', format: :json }

        json = JSON.parse(response.body)
        record = json["data"][0]
        attributes = record["attributes"]

        expect(attributes["readonly_creator_ssim"]["attributes"]["value"]).to eq "Creator and Creator2"
        expect(attributes["readonly_title_ssim"]["attributes"]["value"]).to eq "Item B"
        expect(attributes["readonly_publisher_ssim"]["attributes"]["value"]).to eq "Publisher"
        expect(attributes["readonly_format_ssim"]["attributes"]["value"]).to eq "Visual material"
        expect(attributes["readonly_collections_tesim"]["attributes"]["value"]).to eq "Collection A and Collection B"
      end
    end

    it 'facets upon collections' do
      get :index, params: { q: '' }

      expect(assigns[:response][:facet_counts][:facet_fields]).not_to be_empty
      expect(assigns[:response][:facet_counts][:facet_fields]).to include readonly_collections_ssim: ['Collection A', 1, 'Collection B', 1]
    end

    it 'indexes collections' do
      get :index, params: { q: '' }

      expect(assigns[:response][:response][:docs]).not_to be_empty
      expect(assigns[:response][:response][:docs].first).to include readonly_collections_ssim: ['Collection A', 'Collection B']
    end
  end

  it "can get a single record by its access identifier" do
    index.add(id: "1",
              access_identifier_ssim: "123")
    index.commit

    get :show, params: { id: "123" }

    expect(assigns[:document].id).to eq "1"
  end

  context "when the item does not exist" do
    it "returns a 404 status code response" do
      get :show, params: { id: "no-exist" }
      expect(response.status).to eq 404
    end

    it "returns a 404 status code response for JSON views" do
      get :show, params: { id: "no-exist" }, format: :json
      expect(response.status).to eq 404
    end
  end

  def document_ids
    assigns[:response].documents.map do |x|
      x["id"]
    end
  end

  def index
    Blacklight.default_index.connection
  end
end
