require 'rails_helper'

describe 'Multi image selector', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:site_admin) }
  let(:about_page) { FactoryBot.create(:about_page, exhibit: exhibit) }

  context 'with recorded http interactions', vcr: { cassette_name: 'full_manifest', allow_playback_repeats: true } do
    let(:url) { "https://figgy-staging.princeton.edu/concern/scanned_resources/d26c6d2e-7935-4fff-8a9a-1dfec854d394/manifest" }
    let(:resource) { IIIFResource.new url: url, exhibit: exhibit }

    before do
      resource.save
      resource.reindex
    end

    it 'persists selected image when edit form is re-loaded' do
      solr_doc = nil
      resource.document_builder.to_solr { |x| solr_doc = x }
      sign_in user

      visit spotlight.edit_exhibit_about_page_path(exhibit, about_page)

      add_widget 'solr_documents' # the "Item Row" widget
      fill_in_typeahead_field with: solr_doc[:id]

      expect(page).to have_selector '.panel'

      within('.panel') do
        expect(page).to have_content(/Image \d of \d/)
        expect(page).to have_link 'Change'
        find('a', text: 'Change').click
      end

      expect(page).to have_css('.thumbs-list ul', visible: true)

      within('.thumbs-list ul') do
        all('li')[1].click
      end
      save_page

      # Edit the page again and ensure it has loaded the image we just selected
      click_link('Edit')

      within('.panel') do
        expect(page).to have_content(/Image 2 of \d/)
      end
    end
  end
end
