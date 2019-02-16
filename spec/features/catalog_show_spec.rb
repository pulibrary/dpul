require 'rails_helper'

RSpec.describe 'Catalog', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit Title 1') }
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  let(:document_id) { '1r66j4408' }
  let(:id) { Digest::MD5.hexdigest("#{exhibit.id}-#{document_id}") }
  let(:document) do
    SolrDocument.new(
      id: id
    )
  end

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
        'readonly_description_ssim': [
          "panoramic" * 50
        ],
        'exhibit_exhibit-title-1_readonly_description_ssim': [
          "panoramic" * 50
        ],
        'content_metadata_iiif_manifest_field_ssi': [
          'http://images.institution.edu'
        ]
      }
    )

    document.make_public! exhibit
    document.reindex
    Blacklight.default_index.connection.commit

    Spotlight::CustomField.create!(exhibit: exhibit, slug: 'description', field: 'readonly_description_ssim', configuration: { "label" => "Description" }, field_type: 'vocab', readonly_field: true)
  end

  it 'will add a ... More link in the field' do
    visit spotlight.exhibit_solr_document_path(exhibit, document_id)
    expect(page).to have_content 'panoramic'
    expect(page).to have_selector "a.morelink"
  end

  def index
    Blacklight.default_index.connection
  end
end