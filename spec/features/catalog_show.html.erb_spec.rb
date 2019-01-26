require 'rails_helper'
require 'byebug'

RSpec.feature 'catalog/show.html', type: :feature do
  context 'logged in as a site admin.' do
    let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit D') }
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
        'readonly_description_ssim': [
          "panoramic"*30
        ],
        'readonly_description_tesim': [
          "panoramic"*30
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

    before do
      document.make_public!(exhibit)
      document.reindex
      Blacklight.default_index.connection.commit
      sleep(2)
    end
    
    
    context 'when the document has fields with long content' do
      let(:show_id) {'1r66j4408'}
      # it 'will add a ... More link in the field' do  
      #   visit spotlight.exhibit_solr_document_path(exhibit,show_id)
      #   expect(page).to have_content 'Panoramic'
      #   expect(page).to have_selector '#main-content'
      #   expect(page).to have_selector "#doc_d279a557a62937a8895eebbca2d4744c"
      # end
    end
  end
end
