require 'rails_helper'

RSpec.describe 'Bookmarks', type: :feature, js: true do
  let(:id) { "67890" }
  let(:document) { FactoryBot.build(:document, id: id) }

  before do
    FactoryBot.create(
      :sidecar,
      document: document,
      with_indexed_document: true
    )
    FactoryBot.create(
      :sidecar,
      with_indexed_document: true
    )
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
