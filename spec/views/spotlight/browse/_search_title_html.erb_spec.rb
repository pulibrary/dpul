require 'rails_helper'

RSpec.describe 'spotlight/browse/_search_title', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:search) { exhibit.searches.build(title: 'Search') }

  before do
    assign :exhibit, exhibit
  end

  context 'when browsing all exhibit items' do
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
    let(:id2) { 'b29876d5e07e00acc0b7a4ce6668791d' }
    let(:title2) { 'Panoramic abugida of war' }
    let(:document2) do
      SolrDocument.new(
        id: id2,
        readonly_title_tesim: [
          title2
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
    let(:id3) { '236fa7d48276bf22696de744870e545f' }
    let(:title3) { 'Panoramic abjad of wonder' }
    let(:document3) do
      SolrDocument.new(
        id: id3,
        readonly_title_tesim: [
          title3
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
    let(:search) { exhibit.searches.create(title: 'All Exhibit Items', long_description: 'All items in this exhibit.') }

    before do
      document.make_public! exhibit
      document.reindex
      document2.make_public! exhibit
      document2.reindex
      document3.make_public! exhibit
      document3.reindex
      Blacklight.default_index.connection.commit
    end

    it 'displays the total number of exhibit items' do
      render partial: 'spotlight/browse/search_title', locals: { search: search }
      expect(response).to have_css '.item-count', text: '3 items'
    end

    context 'when Exhibit items are updated as private and deleted' do
      let(:exhibit2) { FactoryBot.create(:exhibit) }
      let(:new_search) { exhibit2.searches.create(title: 'All Exhibit Items', long_description: 'All items in this exhibit.') }

      before do
        assign :exhibit, exhibit2
        document.make_public! exhibit2
        document.reindex
        document2.make_public! exhibit2
        document2.reindex
        document3.make_public! exhibit2
        document3.reindex
        Blacklight.default_index.connection.commit
        new_search
        document2.make_private! exhibit2
        document2.reindex
        Blacklight.default_index.connection.delete_by_id document3.id
        Blacklight.default_index.connection.commit
      end

      it 'displays the total number of exhibit items' do
        render partial: 'spotlight/browse/search_title', locals: { search: new_search }
        expect(response).to have_css '.item-count', text: '1 item'
      end
    end
  end
end
