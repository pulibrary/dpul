require 'rails_helper'

RSpec.describe 'Bookmarks', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit Title', slug: 'exhibit-title') }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  let(:id) { "67890" }
  let(:id2) { "12345" }
  let(:access_id) { '1r66j4408' }
  let(:access_id2) { '2r66j4408' }
  let(:document) { SolrDocument.new(id: id) }
  let(:document2) { SolrDocument.new(id: id2) }

  before do
    sign_in admin
    Spotlight::SolrDocumentSidecar.create!(
      document: document2, exhibit: exhibit,
      data: { "access_identifier_ssim" => [access_id2] }
    )
    Spotlight::SolrDocumentSidecar.create!(
      document: document, exhibit: exhibit,
      data: { "access_identifier_ssim" => [access_id] }
    )

    document.make_public! exhibit
    document2.make_public! exhibit
    document.reindex
    document2.reindex
    Blacklight.default_index.connection.commit
  end

  context "when checking the bookmark box" do
    it "Adds bookmarks to the bookmark page" do
      visit "/catalog?search_field=all_fields&q="
      bookmark_box = "toggle_bookmark_#{id}"
      check bookmark_box
      expect(page).to have_content "In Bookmarks"

      visit "/bookmarks"
      expect(page).to have_content "1 entry found"

      visit "/catalog?search_field=all_fields&q="
      expect(page).to have_content "In Bookmarks"
    end
  end
end
