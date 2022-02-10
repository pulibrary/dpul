# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Catalog', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit A') }
  let(:id) { 'd279a557a62937a8895eebbca2d4744c' }
  let(:title) { 'Panoramic alphabet of peace' }
  let(:rights) { 'http://rightsstatements.org/vocab/NKC/1.0/' }
  let(:document) do
    SolrDocument.new(
      id: id,
      readonly_title_tesim: [
        title
      ],
      'exhibit_abc_books_readonly_edm-rights_ssim': [
        rights
      ],
      'readonly_edm-rights_tesim': [
        rights
      ],
      exhibit_abc_books_readonly_license_ssim: [
        rights
      ],
      readonly_license_tesim: [
        rights
      ],
      access_identifier_ssim: [
        "1r66j4408"
      ],
      full_title_tesim: [
        title
      ],
      readonly_title_ssim: [
        title
      ],
      'readonly_title-sort_ssim': [
        title
      ],
      'readonly_edm-rights_ssim': [
        rights
      ],
      readonly_license_ssim: [
        rights
      ],
      _version_: 159,
      timestamp: "2018-02-19T22:19:52.244Z"
    )
  end

  context 'logged in as a site admin.' do
    let(:user) { FactoryBot.create(:site_admin, exhibit: exhibit) }

    before do
      sign_in user

      Spotlight::SolrDocumentSidecar.create!(
        document: document, exhibit: exhibit,
        data: { 'full_title_tesim' => ['First', 'Second'] }
      )
      document.make_public! exhibit
      document.reindex
      index.commit
    end

    scenario 'user tries autocomplete' do
      visit spotlight.autocomplete_exhibit_catalog_path(exhibit_id: exhibit.id, q: " ", format: "json")

      expect(JSON.parse(page.body)["docs"].length).to eq 1
      doc = JSON.parse(page.body)["docs"].first
      # Autocomplete should have a title with no HTML. If there's HTML it breaks
      # the SirTrevor widgets.
      expect(doc["title"]).to eq "First, Second"
    end

    scenario 'user searches for a collections with a keyword' do
      visit spotlight.search_exhibit_catalog_path(exhibit, search_field: 'all_fields', q: id)
      expect(page).to have_css '#documents .document h3.index_title', text: 'First'
    end

    context 'when the document has metadata attributes with quotes' do
      before do
        exhibit2 = Spotlight::Exhibit.create title: 'Exhibit B', published: true
        document2 = SolrDocument.new(id: 'd279a557a62937a8895eebbca2d4744c', exhibit: exhibit)
        Spotlight::SolrDocumentSidecar.delete_all
        Spotlight::SolrDocumentSidecar.create!(
          document: document2, exhibit: exhibit2,
          data: { 'full_title_tesim' => ['"title1"'] }
        )
        document2.make_private!(exhibit2)
        document2.save
        index.commit
      end

      scenario 'user searches for a collections with a keyword in quotes' do
        visit spotlight.search_exhibit_catalog_path(exhibit, search_field: 'all_fields', q: '"title1"')
        expect(page).to have_css '#documents .document h3.index_title', text: '"title1"'
      end
    end

    scenario 'user browses all collections' do
      visit spotlight.search_exhibit_catalog_path(exhibit, search_field: 'all_fields', q: '')
      expect(page).to have_link 'Home', href: "/#{exhibit.slug}"
      expect(page).to have_css '#documents .document h3.index_title', text: 'First'
    end

    scenario "cross-collection search links to the search result with no exhibit context" do
      visit main_app.search_catalog_path(q: '')

      expect(page).not_to have_link id, href: "/slug-1/catalog/#{id}"
      expect(page).to have_link 'First', href: "/catalog/#{id}"
    end
  end

  context 'when searching across a catalog with many languages' do
    let(:languages) {
      [
        'Language 1',
        'Language 2',
        'Language 3',
        'Language 4',
        'Language 5',
        'Language 6',
        'Language 7',
        'Language 8',
        'Language 9',
        'Language 10',
        'Language 11'
      ]
    }

    before do
      index.add(id: '1',
                full_title_ssim: ['Test Item'],
                readonly_title_ssim: ['Test Item'],
                spotlight_resource_type_ssim: ['iiif_resources'],
                readonly_language_ssim: languages)
      index.commit
    end

    it 'renders the languages facet with a more facets link' do
      visit main_app.search_catalog_path(q: '')
      expect(page).to have_link("more", href: '/catalog/facet/readonly_language_ssim')
    end

    it "displays a sort", js: true do
      visit main_app.search_catalog_path(q: '')

      expect(page).to have_selector "#sort-dropdown"
    end
  end

  def index
    Blacklight.default_index.connection
  end

  context "when a resource belongs to 2 different exhibits" do
    it "retrieves the correct solr document for each" do
      url = 'https://figgy.princeton.edu/concern/ephemera_folders/e41da87f-84af-4f50-ab69-781576cf82db/manifest'
      stub_manifest(url: url, fixture: 'full_text_manifest.json')
      stub_metadata(id: "e41da87f-84af-4f50-ab69-781576cf82db")
      stub_ocr_content(id: "e41da87f-84af-4f50-ab69-781576cf82db", text: "More searchable text")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A', published: true, slug: "exhibit_a"
      resource = IIIFResource.new(url: url, exhibit: exhibit)
      resource.save_and_index_now

      exhibit2 = Spotlight::Exhibit.create title: 'Exhibit B', published: true, slug: "exhibit_b"
      resource2 = IIIFResource.new(url: url, exhibit: exhibit2)
      resource2.save_and_index_now
      Blacklight.default_index.connection.commit

      visit spotlight.raw_exhibit_catalog_path(exhibit, id: resource.noid)
      json = JSON.parse(page.body)
      expect(json.keys).to include "exhibit_exhibit_a_public_bsi"

      visit spotlight.raw_exhibit_catalog_path(exhibit2, id: resource.noid)
      json = JSON.parse(page.body)
      expect(json.keys).to include "exhibit_exhibit_b_public_bsi"
    end
  end
end
