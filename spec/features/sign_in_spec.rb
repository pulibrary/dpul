require 'rails_helper'

RSpec.feature 'Home Page', type: :feature do
  context 'a logged in site admin' do
    let(:user) { FactoryGirl.create(:site_admin) }

    before(:each) do
      sign_in user
    end

    scenario 'site admins can create exhibits' do
      visit root_path
      expect(page).to have_link "Create Exhibit"
    end
  end

  context "while not logged in" do
    scenario "it doesn't show links to create exhibits" do
      visit root_path
      expect(page).not_to have_link 'Create Exhibit'
    end
  end
end
