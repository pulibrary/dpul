# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookmarks', type: :feature, js: true do
  with_queue_adapter :inline
  let(:iiif_resource1) do FactoryBot.create(
    :iiif_resource,
    url: "https://figgy.princeton.edu/concern/scanned_resources/beaec815-6a34-4519-8ce8-40a89d3b1956/manifest",
    exhibit:,
    manifest_fixture: "paris_map.json",
    figgy_uuid: "beaec815-6a34-4519-8ce8-40a89d3b1956",
    spec: self
  )
  end

  let(:iiif_resource2) do FactoryBot.create(
    :iiif_resource,
    url: "https://figgy.princeton.edu/concern/scanned_resources/0cc43bdb-ae21-47b2-90bc-bc21a18ee821/manifest",
    exhibit:,
    manifest_fixture: "chinese_medicine.json",
    figgy_uuid: "0cc43bdb-ae21-47b2-90bc-bc21a18ee821",
    spec: self
  )
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:solr_id) { iiif_resource1.solr_documents.first[:id] }
  let(:title) { "Plan de Paris : commencé de l'année 1734" }

  context "when checking the bookmark box" do
    it "Adds bookmarks to the bookmark page, shows bookmark in exhibit context" do
      iiif_resource1
      iiif_resource2
      visit spotlight.search_exhibit_catalog_path(exhibit, search_field: 'all_fields', q: '')
      bookmark_box = "toggle-bookmark_#{solr_id}"
      check bookmark_box
      expect(page).to have_content "In Bookmarks"

      visit "/bookmarks"
      expect(page).to have_content "1 entry found"
      expect(page).to have_link "CSV"
      expect(page).to have_link "Email"
      expect(page).to have_link "Cite"

      page.click_on title
      expect(page).to have_current_path spotlight.exhibit_solr_document_path(exhibit, iiif_resource1.noid)

      visit "/catalog?search_field=all_fields&q="
      expect(page).to have_content "In Bookmarks"

      # Exhibit was destroyed, leaving an orphaned Resource.
      # @TODO Make this case impossible to reach.
      exhibit.destroy
      visit "/bookmarks"
      expect(page).to have_content "1 entry found"
    end
  end
end
