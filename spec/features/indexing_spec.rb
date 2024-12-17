# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Indexing a figgy collection end-to-end test", type: :feature, js: true do
  context "when a collection has a custom label on a field and a resource with an override title" do
    with_queue_adapter :inline
    let(:exhibit) { FactoryBot.create(:exhibit, title: "princeton", slug: "princeton-best") }

    scenario "the field with the custom label indexes a value" do
      sign_in FactoryBot.create(:site_admin)
      stub_collections(fixture: "collections.json")
      stub_manifest(url: "https://hydra-dev.princeton.edu/collections/2b88qc199/manifest", fixture: "2b88qc199.json")
      stub_manifest(url: "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest", fixture: "1r66j1149.json")
      stub_metadata(id: "1234567", fixture: "beaec815-6a34-4519-8ce8-40a89d3b1956")
      stub_manifest(url: "https://hydra-dev.princeton.edu/concern/scanned_resources/44558d29f/manifest", fixture: "44558d29f.json")
      Spotlight::ReindexExhibitJob.perform_now(exhibit)

      # Add an override title
      # visit "/princeton-best/catalog/7w62fb79e"
      # click_link "Edit"
      # fill_in "solr_document_sidecar_data_override-title_ssim", with: "Grecian Temples"
      # click_button "Save changes"
      # expect(page).to have_content "Grecian Temples"

      # before changing the label, the field is there
      visit "/princeton-best/catalog/7w62fb79g"
      expect(page).to have_content "Alternative"

      visit "/princeton-best/metadata_configuration/edit"

      expect(page).not_to have_content "Alternative title"
      within(find("tr[data-id='readonly_alternative_ssim']")) do
        find("a.edit-in-place").click
        find("#blacklight_configuration_index_fields_readonly_alternative_ssim_label", visible: :all).set("Alternative title")
      end
      click_button "Save changes"
      expect(page).to have_content "Alternative title"

      Spotlight::ReindexExhibitJob.perform_now(exhibit)

      # after changing the label and reindexing, the field is still there
      visit "/princeton-best/catalog/7w62fb79g"
      expect(page).to have_content "Alternative"
    end
  end
end
