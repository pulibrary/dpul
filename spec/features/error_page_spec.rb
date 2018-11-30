require 'rails_helper'

RSpec.describe 'Error Pages', type: :feature do
  context "when visiting the pages directly" do
    it "shows a custom 404 page" do
      visit "/404"
      expect(page).to have_selector ".site-title", text: "We Can't Find That Page"
    end

    it "shows a custom 500 page" do
      visit "/500"
      expect(page).to have_selector ".site-title", text: "Server Error"
    end
  end

  context "when triggering the error" do
    it "shows a custom 404 page" do
      visit "/catalog/nonexistent"
      expect(page).to have_selector ".site-title", text: "We Can't Find That Page"
    end
  end
end
