require 'rails_helper'

RSpec.describe 'Catalog', type: :feature, js: true do
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
        readonly_collections_tesim: [
          'test collection 1',
          'test collection 2'
        ],
        'exhibit_exhibit-title-1_readonly_collections_ssim': [
          'test collection 1',
          'test collection 2'
        ],
        readonly_description_ssim: [
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

    Spotlight::CustomField.create!(exhibit: exhibit, slug: 'collections', field: 'readonly_collections_ssim', configuration: { "label" => "Collections" }, field_type: 'vocab', readonly_field: true)
    collection1
    collection2
    Spotlight::CustomField.create!(exhibit: exhibit, slug: 'description', field: 'readonly_description_ssim', configuration: { "label" => "Description" }, field_type: 'vocab', readonly_field: true)
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

  context 'when the view_context is not available' do
    # Ensures that this not a double
    let(:view_context) { Object.new }
    let(:collection1) { Spotlight::Exhibit.create!(title: 'test collection 1') }
    let(:collection2) { Spotlight::Exhibit.create!(title: 'test collection 2') }

    before do
      allow(Rails.logger).to receive(:error)
      allow_any_instance_of(RTLShowPresenter).to receive(:view_context).and_return(view_context)
    end

    it 'does not render the collection titles as links and logs an error' do
      visit spotlight.exhibit_solr_document_path(exhibit, document_id)
      expect(page).not_to have_link 'test collection 1'
      expect(page).not_to have_link 'test collection 2'
      expect(page).to have_content 'test collection 1'
      expect(page).to have_content 'test collection 2'
      expect(Rails.logger).to have_received(:error).with("Failed to render the link to the collection test collection 1 for #{collection1.id}")
      expect(Rails.logger).to have_received(:error).with("Failed to render the link to the collection test collection 2 for #{collection2.id}")
    end
  end

  def index
    Blacklight.default_index.connection
  end
end
