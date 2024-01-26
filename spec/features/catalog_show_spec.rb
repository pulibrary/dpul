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

  context "when there are multiple descriptions" do
    let(:sidecar_data) do
      {
        document:,
        exhibit:,
        data: {
          full_title_tesim: [
            'test item'
          ],
          'exhibit_exhibit-title-1_readonly_description_ssim': [
            "Asra – Asra Panahi was a 15-year-old schoolgirl who died in Ardabil, a city in the northwest of Iran. She was one of several students who were beaten by security forces during a raid on her school, when they refused to sing an anthem praising the supreme leader, Ali Khamenei. She died later in hospital from her injuries, on October 13, 2022.",
            "Berlin – The Iranian protest in Berlin, held on October 22, 2022, showcased a largest demonstration of solidarity in response to ongoing protests in Iran. With a turnout of approximately 80,000 demonstrators, this gathering represented a significant milestone, as it stood as the largest demonstration ever organized by the Iranian diaspora.",
            "Fatemeh-Sepehri – Fatemeh Sepehri, a prominent political activist imprisoned in Iran, was arrested on September 21, 2022, during nationwide protests following the police killing of Mahsa Jina Amini's death. She criticized state religious policies and government mandates, receiving an 18-year prison sentence on charges like propaganda against the regime,insulting Khomeini and Khamenei, and colluding against national security. In 2019, she was among 14 signatories of a letter seeking Khamenei's resignation and the establishment of a secular government.",
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
