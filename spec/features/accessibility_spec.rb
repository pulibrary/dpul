# frozen_string_literal: true

require 'rails_helper'

describe "accessibility", type: :feature, js: true do
  context "when visiting bookmarks page" do
    with_queue_adapter :inline
    let(:iiif_resource1) do FactoryBot.create(
      :iiif_resource,
      url: "https://figgy.princeton.edu/concern/scanned_resources/beaec815-6a34-4519-8ce8-40a89d3b1956/manifest",
      exhibit: exhibit,
      manifest_fixture: "paris_map.json",
      figgy_uuid: "beaec815-6a34-4519-8ce8-40a89d3b1956",
      spec: self
    )
    end
    let(:iiif_resource2) do FactoryBot.create(
      :iiif_resource,
      url: "https://figgy.princeton.edu/concern/scanned_resources/0cc43bdb-ae21-47b2-90bc-bc21a18ee821/manifest",
      exhibit: exhibit,
      manifest_fixture: "chinese_medicine.json",
      figgy_uuid: "0cc43bdb-ae21-47b2-90bc-bc21a18ee821",
      spec: self
    )
    end

    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:solr_id) { iiif_resource1.solr_documents.first[:id] }
    let(:title) { "Plan de Paris : commencé de l'année 1734" }

    it "complies with WCAG" do
      iiif_resource1
      iiif_resource2
      visit spotlight.search_exhibit_catalog_path(exhibit, search_field: 'all_fields', q: '')
      bookmark_box = "toggle-bookmark_#{solr_id}"
      check bookmark_box
      visit "/bookmarks"

      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        .excluding(".tt-hint") # Issue is in typeahead.js library
    end
  end

  context "when browsing exhibit items page" do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:user) { FactoryBot.create(:site_admin, exhibit: exhibit) }
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

    it "complies with WCAG" do
      sign_in user
      document.make_public! exhibit
      document.reindex
      Blacklight.default_index.connection.commit
      visit spotlight.exhibit_browse_path(exhibit, id: 'all-exhibit-items')

      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        .excluding(".tt-hint") # Issue is in typeahead.js library
        .excluding(".nav-link") # Color constrast valid, but test fails because of navbar's transparency and no img loading
    end
  end

  context "when visiting bulk actions page" do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

    it "complies with WCAG" do
      sign_in admin
      d = SolrDocument.new(id: 'dq287tq6352')
      exhibit.tag(d.sidecar(exhibit), with: ['foo'], on: :tags)
      d.make_private! exhibit
      d.reindex
      Blacklight.default_index.connection.commit
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'dq287tq6352')

      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        .excluding(".tt-hint") # Issue is in typeahead.js library
        .excluding(".nav-link") # Color constrast valid, but test fails because of navbar's transparency and no img loading
        .skipping(:"duplicate-id-aria") # See issue: #1264
        .skipping(:"duplicate-id") # See issue: #1227
    end
  end

  context "when visiting catalog show page" do
    let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit Title 1', slug: 'exhibit-title-1') }
    let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
    let(:document_id) { '1r66j4408' }
    let(:id) { Digest::MD5.hexdigest("#{exhibit.id}-#{document_id}") }
    let(:document) do
      SolrDocument.new(
        id: id
      )
    end
    let(:collection1) { Spotlight::Exhibit.create!(title: 'test collection 1') }
    let(:collection2) { Spotlight::Exhibit.create!(title: 'test collection 2') }

    before do
      sign_in admin
      Spotlight::SolrDocumentSidecar.create!(
        document: document, exhibit: exhibit,
        data: {
          full_title_tesim: [
            'test item'
          ],
          access_identifier_ssim: [
            "1r66j4408"
          ],
          readonly_collections_ssim: [
            'test collection 1',
            'test collection 2'
          ],
          'exhibit_exhibit-title-1_readonly_collections_ssim': [
            'test collection 1',
            'test collection 2'
          ],
          readonly_description_ssim: [
            "panoramic" * 150
          ],
          'exhibit_exhibit-title-1_readonly_description_ssim': [
            "panoramic" * 150
          ],
          'content_metadata_iiif_manifest_field_ssi': [
            'http://images.institution.edu'
          ]
        }
      )
      document.make_public! exhibit
      document.reindex
      Blacklight.default_index.connection.commit
      Spotlight::CustomField.create!(exhibit: exhibit, slug: 'collections', field: 'readonly_collections_ssim', configuration: { "label" => "Collections" }, field_type: 'vocab', readonly_field: true)
      collection1
      collection2
      Spotlight::CustomField.create!(exhibit: exhibit, slug: 'description', field: 'readonly_description_ssim', configuration: { "label" => "Description" }, field_type: 'vocab', readonly_field: true)
    end

    it "complies with WCAG" do
      visit spotlight.exhibit_solr_document_path(exhibit, document_id)

      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        .excluding(".tt-hint") # Issue is in typeahead.js library
        .skipping(:"duplicate-id") # See issue #1336
        .skipping(:"color-contrast") # See issue: #1265
        .skipping(:"link-in-text-block") # see #1413
    end
  end

  context "when visiting catalog page" do
    let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit A') }
    let(:user) { FactoryBot.create(:site_admin, exhibit: exhibit) }
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

    context "with search exhibit catalog path" do
      it "complies with WCAG" do
        sign_in user
        document.make_public! exhibit
        document.reindex
        index.commit
        visit spotlight.search_exhibit_catalog_path(exhibit, search_field: 'all_fields', q: '')

        expect(page).to be_axe_clean
          .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
          .excluding(".tt-hint") # Issue is in typeahead.js library
          .skipping(:"color-contrast") # See issue: #1265
          .skipping(:"duplicate-id-aria") # See issue: #1264
          .skipping(:"duplicate-id") # See issue: #1227
      end
    end

    context "when searching across a catalog with many languages" do
      let(:languages) {
        [
          'Language 1',
          'Language 2',
          'Language 3',
          'Language 4'
        ]
      }

      it "complies with WCAG" do
        index.add(id: '1',
                  full_title_ssim: ['Test Item'],
                  readonly_title_ssim: ['Test Item'],
                  spotlight_resource_type_ssim: ['iiif_resources'],
                  readonly_language_ssim: languages)
        index.commit
        visit main_app.search_catalog_path(q: '')

        expect(page).to be_axe_clean
          .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
          .excluding(".tt-hint") # Issue is in typeahead.js library
      end
    end

    def index
      Blacklight.default_index.connection
    end
  end

  context "when visiting edit page" do
    let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit Title 1', slug: 'exhibit-title-1') }
    let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
    let(:id) { Digest::MD5.hexdigest("#{exhibit.id}-#{document_id}") }
    let(:document_id) { '1r66j4408' }
    let(:document) do
      SolrDocument.new(
        id: id
      )
    end
    let(:collection1) { Spotlight::Exhibit.create!(title: 'test collection 1') }
    let(:collection2) { Spotlight::Exhibit.create!(title: 'test collection 2') }

    before do
      sign_in admin
      Spotlight::SolrDocumentSidecar.create!(
        document: document, exhibit: exhibit,
        data: {
          "override-title_ssim": nil,
          full_title_tesim: [
            'test item'
          ],
          access_identifier_ssim: [
            "1r66j4408"
          ],
          readonly_collections_ssim: [
            'test collection 1',
            'test collection 2'
          ],
          'content_metadata_iiif_manifest_field_ssi': [
            'http://images.institution.edu'
          ]
        }.stringify_keys
      )
      document.make_public! exhibit
      document.reindex
      Blacklight.default_index.connection.commit
      Spotlight::CustomField.create!(exhibit: exhibit, slug: 'collections', field: 'readonly_collections_ssim', configuration: { "label" => "Collections" }, field_type: 'vocab', readonly_field: true)
      Spotlight::CustomField.create!(exhibit: exhibit, slug: 'override-title_ssim', field: 'override-title_ssim', configuration: { "label" => "Override Title" }, field_type: 'vocab', readonly_field: false)
    end

    it "complies with WCAG" do
      visit "/#{exhibit.slug}/catalog/#{document_id}/edit"

      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        .excluding(".tt-hint") # Issue is in typeahead.js library
        .skipping(:"duplicate-id") # See issue #1336
        .skipping(:"color-contrast") # See issue: #1265
    end
  end

  context "when visiting error page" do
    context "with 404 error" do
      it "complies with WCAG" do
        visit "/404"
        expect(page).to be_axe_clean
          .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
          .excluding(".tt-hint") # Issue is in typeahead.js library
      end
    end

    context "with 500 error" do
      it "complies with WCAG" do
        visit "/500"
        expect(page).to be_axe_clean
          .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
          .excluding(".tt-hint") # Issue is in typeahead.js library
          .skipping(:"link-in-text-block") # see #1413
      end
    end

    context "with nonexistent page" do
      it "complies with WCAG" do
        visit "/catalog/nonexistent"
        expect(page).to be_axe_clean
          .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
          .excluding(".tt-hint") # Issue is in typeahead.js library
      end
    end
  end

  context "when visiting exhibit home page" do
    let(:exhibit) { FactoryBot.create(:exhibit, subtitle: "بي") }
    let(:user) { FactoryBot.create(:site_admin) }

    context "when logged in as a site admin" do
      it "complies with WCAG" do
        sign_in user
        visit spotlight.exhibit_root_path exhibit

        expect(page).to be_axe_clean
          .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
          .excluding(".tt-hint") # Issue is in typeahead.js library
          .skipping(:"link-in-text-block") # see #1413
      end
    end

    context "when not logged in" do
      it "complies with WCAG" do
        visit spotlight.exhibit_root_path exhibit
        expect(page).to be_axe_clean
          .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
          .excluding(".tt-hint") # Issue is in typeahead.js library
          .skipping(:"link-in-text-block") # see #1413
      end
    end
  end

  context "when visiting language create edit page" do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

    it "complies with WCAG" do
      login_as admin
      visit spotlight.edit_exhibit_path(exhibit)

      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        .excluding(".tt-hint") # Issue is in typeahead.js library
        .skipping(:"color-contrast") # See issue: #1265
        .skipping(:"duplicate-id") # See issue: #1227
    end
  end

  context "when visiting sign in page" do
    context "when logged in as site admin" do
      let(:user) { FactoryBot.create(:site_admin) }

      it "complies with WCAG" do
        sign_in user
        visit root_path

        expect(page).to be_axe_clean
          .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
          .excluding(".tt-hint") # Issue is in typeahead.js library
          .skipping(:"link-in-text-block") # see #1413
      end
    end

    context "when not logged in" do
      it "complies with WCAG" do
        visit root_path
        expect(page).to be_axe_clean
          .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
          .excluding(".tt-hint") # Issue is in typeahead.js library
          .skipping(:"link-in-text-block") # see #1413
      end
    end
  end
end
