# frozen_string_literal: true

require 'rails_helper'

# This tests a regression introduced in cancancan 3.2.0.
# See issue: https://github.com/CanCanCommunity/cancancan/issues/677
# We think by the time we upgrade cancan again there may be a released fix.
# If at that point things are still broken we can try this monkey patch
# https://github.com/sul-dlss/exhibits/commit/298653db0e5cd32f0fa5ffcf5612b0e858124ef9
RSpec.describe "Pages requests", type: :request do
  context "with a user who is an admin on an exhibit" do
    it "can access all the pages when fetching pages.json (and therefore autocomplete the pages widget)" do
      exhibit = FactoryBot.create(:exhibit)
      user = FactoryBot.create(:exhibit_admin, exhibit: exhibit)
      FactoryBot.create(:feature_page, exhibit: exhibit)

      sign_in user
      get "/#{exhibit.slug}/pages.json"

      # 1 is feature page, 1 for exhibit home page.
      expect(JSON.parse(response.body).length).to eq 2
    end
  end
end
