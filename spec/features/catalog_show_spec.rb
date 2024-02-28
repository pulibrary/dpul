# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalog', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit Title 1', slug: 'exhibit-title-1') }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit:) }
  let(:document_id) { '1r66j4408' }
  let(:id) { Digest::MD5.hexdigest("#{exhibit.id}-#{document_id}") }
  let(:document) do
    SolrDocument.new(
      id:
    )
  end
  let(:collection1) { Spotlight::Exhibit.create!(title: 'test collection 1') }
  let(:collection2) { Spotlight::Exhibit.create!(title: 'test collection 2') }
  let(:sidecar_data) do
    {
      document:, exhibit:,
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
        ],
        "exhibit_exhibit-title-1_readonly_author_ssim": [
          "Vasi"
        ],
        "readonly_author_tesim": [
          "Vasi"
        ]
      }
    }
  end

  before do
    sign_in admin
    Spotlight::SolrDocumentSidecar.create!(sidecar_data)

    document.make_public! exhibit
    document.reindex
    Blacklight.default_index.connection.commit

    Spotlight::CustomField.create!(exhibit:, slug: 'collections', field: 'readonly_collections_ssim', configuration: { "label" => "Collections" }, field_type: 'vocab', readonly_field: true)
    collection1
    collection2
    Spotlight::CustomField.create!(exhibit:, slug: 'description', field: 'readonly_description_ssim', configuration: { "label" => "Description" }, field_type: 'vocab', readonly_field: true)
  end

  it 'will add a ... More link in the field' do
    visit spotlight.exhibit_solr_document_path(exhibit, document_id)
    expect(page).to have_content 'panoramic'
    expect(page).to have_selector "a.morelink"
  end

  it 'will render the collection titles as links' do
    visit spotlight.exhibit_solr_document_path(exhibit, document_id)
    expect(page).to have_link 'test collection 1', href: '/test-collection-1'
    expect(page).to have_link 'test collection 2', href: '/test-collection-2'
  end

  it "renders the correct facet link" do
    # the value of link_to_facet into the configuration needs to match the field name
    exhibit.blacklight_configuration.index_fields["readonly_author_ssim"] = { "label" => "Author", "link_to_facet" => "readonly_author_ssim", "list" => true, "show" => true, "enabled" => true }
    exhibit.blacklight_configuration.save
    Spotlight::CustomField.create!(exhibit:, slug: 'author', field: 'readonly_author_ssim', configuration: { "label" => "Author" }, field_type: 'vocab', readonly_field: true)

    visit spotlight.exhibit_solr_document_path(exhibit, document_id)
    expect(page).to have_link 'Vasi', href: '/exhibit-title-1/catalog?f%5Breadonly_author_ssim%5D%5B%5D=Vasi'
  end

  context "when there are multiple descriptions of significant length" do
    let(:sidecar_data) do
      {
        document:,
        exhibit:,
        data: {
          full_title_tesim: [
            'test item'
          ],
          'exhibit_exhibit-title-1_readonly_description_ssim': [
            "Asra",
            "Berlin " * 400
          ],
          'content_metadata_iiif_manifest_field_ssi': [
            'http://images.institution.edu'
          ]
        }
      }
    end

    it "renders them each in their own list item" do
      visit spotlight.exhibit_solr_document_path(exhibit, document_id)
      within "dd.blacklight-readonly_description_ssim ul" do
        expect(page).to have_content "Berlin"
      end
    end
  end

  def index
    Blacklight.default_index.connection
  end
end
