# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalog Edit', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit Title 1', slug: 'exhibit-title-1') }
  let(:different_exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit Title 2', slug: 'exhibit-title-2') }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  let(:document_id) { '1r66j4408' }
  let(:id) { Digest::MD5.hexdigest("#{exhibit.id}-#{document_id}") }
  let(:id2) { Digest::MD5.hexdigest("#{different_exhibit.id}-#{document_id}") }
  let(:document) do
    SolrDocument.new(
      id: id
    )
  end
  let(:document2) do
    SolrDocument.new(
      id: id2
    )
  end
  let(:collection1) { Spotlight::Exhibit.create!(title: 'test collection 1') }
  let(:collection2) { Spotlight::Exhibit.create!(title: 'test collection 2') }

  before do
    sign_in admin
    Spotlight::SolrDocumentSidecar.create!(
      document: document2, exhibit: different_exhibit,
      data: {
        "override-title_ssim": "bla",
        full_title_tesim: [
          'test item'
        ],
        access_identifier_ssim: [
          "1r66j4408"
        ],
        readonly_collections_ssim: [
          'test collection 3'
        ],
        'content_metadata_iiif_manifest_field_ssi': [
          'http://images.institution.edu'
        ]
      }.stringify_keys
    )
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
    document2.make_public! different_exhibit
    document.reindex
    document2.reindex
    Blacklight.default_index.connection.commit

    Spotlight::CustomField.create!(exhibit: exhibit, slug: 'collections', field: 'readonly_collections_ssim', configuration: { "label" => "Collections" }, field_type: 'vocab', readonly_field: true)
    Spotlight::CustomField.create!(exhibit: exhibit, slug: 'override-title_ssim', field: 'override-title_ssim', configuration: { "label" => "Override Title" }, field_type: 'vocab', readonly_field: false)
  end

  it "can be edited without losing data" do
    visit "/#{exhibit.slug}/catalog/#{document_id}/edit"
    fill_in "Override Title", with: "Test Override Title"
    expect(page).to have_field "Collections", with: "test collection 1 test collection 2"
    click_button "Save changes"
    click_link "Edit"
    expect(page).to have_field "Collections", with: "test collection 1 test collection 2"
    expect(page).to have_content "test collection 1"
    expect(page).to have_content "Test Override Title"
  end

  def index
    Blacklight.default_index.connection
  end
end
