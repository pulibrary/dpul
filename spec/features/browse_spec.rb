# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Browsing exhibits', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:user, exhibit: exhibit) }
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

  before do
    sign_in user
    document.make_public! exhibit
    document.reindex
    document2.make_public! exhibit
    document2.reindex
    document3.make_public! exhibit
    document3.reindex
    Blacklight.default_index.connection.commit
  end

  context 'when logged in as a site admin.' do
    let(:user) { FactoryBot.create(:site_admin, exhibit: exhibit) }

    context 'when browsing all exhibit items' do
      before do
        visit spotlight.exhibit_browse_path(exhibit, id: 'all-exhibit-items')
      end

      it 'displays the total number of publicly accessible items' do
        expect(page).to have_css '.item-count', text: '3 items'
      end
    end

    context 'when browsing all exhibit items in a saved search' do
      before do
        exhibit.searches.create(title: 'All Exhibit Items', long_description: 'All items in this exhibit.')

        document2.make_private! exhibit
        document2.reindex
        Blacklight.default_index.connection.delete_by_id document3.id
        Blacklight.default_index.connection.commit

        visit spotlight.exhibit_browse_path(exhibit, id: 'all-exhibit-items')
      end

      it 'hides the privately accessible items and updates for deleted items' do
        expect(page).to have_css '.item-count', text: '1 item'
      end
    end
  end
end
