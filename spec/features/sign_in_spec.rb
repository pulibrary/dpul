# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home Page', type: :feature, js: true do
  context 'a logged in site admin' do
    let(:user) { FactoryBot.create(:site_admin) }

    before do
      sign_in user
    end

    scenario 'site admins can create exhibits' do
      visit root_path
      expect(page).to have_link "Create Collection"
    end
  end

  context "while not logged in" do
    scenario "it doesn't show links to create exhibits" do
      visit root_path
      expect(page).not_to have_link 'Create Collection'
    end
  end
end
