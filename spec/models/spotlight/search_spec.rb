# frozen_string_literal: true

require 'rails_helper'

describe Spotlight::Search, type: :model do
  subject(:search) { exhibit.searches.build(title: 'Search') }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:blacklight_config) { ::CatalogController.blacklight_config }
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
    document.make_public! exhibit
    document.reindex
    document2.make_public! exhibit
    document2.reindex
    document3.make_public! exhibit
    document3.reindex
    Blacklight.default_index.connection.commit
  end

  context 'when Exhibit items are updated as private and deleted' do
    subject(:new_search) { exhibit.searches.create(title: 'All Exhibit Items', long_description: 'All items in this exhibit.') }

    before do
      new_search
      document2.make_private! exhibit
      document2.reindex
      Blacklight.default_index.connection.delete_by_id document3.id
      Blacklight.default_index.connection.commit
    end

    describe '#documents' do
      it 'retrieves the updated documents' do
        expect(new_search.documents.to_a).not_to be_empty
        expect(new_search.documents.size).to eq 1
      end
    end

    describe '#count' do
      it 'counts the updated documents' do
        expect(search.count).to eq 1
        expect(search.count).to eq search.documents.size
      end
    end
  end

  context 'when creating a search to browse all items in an Exhibit' do
    subject(:search) do
      exhibit.searches.create(title: 'All Exhibit Items', long_description: 'All items in this exhibit.')
    end

    describe '#documents' do
      it 'retrieves all documents within an exhibit' do
        expect(search.documents.to_a).not_to be_empty
        expect(search.documents.size).to eq 3
        expect(search.documents.first).to be_a SolrDocument
      end
    end

    describe '#count' do
      it 'counts all documents within an exhibit' do
        expect(search.count).to eq 3
        expect(search.count).to eq search.documents.size
      end
    end
  end
end
