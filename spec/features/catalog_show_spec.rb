require 'rails_helper'
require 'byebug'

RSpec.feature 'Catalog', type: :feature do
    #let(:exhibit) { instance_double(Spotlight::Exhibit) }
    #let(:document) { instance_double(SolrDocument) }
    let(:user) { FactoryBot.create(:site_admin, exhibit: exhibit) }
    let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit D', slug: 'exhibit-d') }
  
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
      ]
      )
    end



    before do
      
      Spotlight::SolrDocumentSidecar.create!(
        document: document, exhibit: exhibit,
        data: { 'full_title_tesim' => ['"title1"'] }
      )
      sign_in user
      index.add(document)
      document.make_public! exhibit
      document.reindex
      index.commit
      #allow(exhibit).to receive(:slug).and_return('exhibit-d')
      allow(exhibit).to receive(:exhibit).and_return('exhibit-d')
      # allow(document).to receive(:document)#.and_return('d279a557a62937a8895eebbca2d4744c')
    end
      
    it 'will add a ... More link in the field' do
      byebug
      visit spotlight.exhibit_solr_document_path("exhibit-d","1r66j4408")
      expect(page).to have_content 'Panoramic'
    #   expect(page).to have_selector '#main-content'
    #   expect(page).to have_selector "#doc_d279a557a62937a8895eebbca2d4744c"
    end

    def index
      Blacklight.default_index.connection
    end

end
