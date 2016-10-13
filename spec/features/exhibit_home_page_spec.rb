require 'rails_helper'

RSpec.feature 'Exhibit Home Page', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  context 'a logged in site admin' do
    let(:user) { FactoryGirl.create(:site_admin) }
    before do
      sign_in user
    end

    scenario 'site admins see dashboard and edit buttons' do
      visit spotlight.exhibit_root_path exhibit
      expect(page).to have_selector 'a.btn', text: 'Dashboard'
      expect(page).to have_selector 'a.btn', text: 'Edit'
    end
  end

  context "while not logged in" do
    scenario "it doesn't show links to create exhibits" do
      visit spotlight.exhibit_root_path exhibit
      expect(page).not_to have_link 'Dashboard'
      expect(page).not_to have_link 'Edit'
    end
  end
end
