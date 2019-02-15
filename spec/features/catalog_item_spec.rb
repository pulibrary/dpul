require 'rails_helper'

describe 'Catalog', type: :feature do
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
          "panoramic" * 30
        ],
        'exhibit_exhibit-title-1_readonly_description_ssim': [
          "panoramic" * 30
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

  describe 'viewing the page' do
    it 'renders the page' do
      visit spotlight.exhibit_solr_document_path(exhibit, '1r66j4408')
      expect(page).to have_content 'panoramic'
    end
  end
end
