# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "pages routing" do
  describe "GET /robots.txt" do
    it "routes to the pages controller" do
      expect(get("/robots.txt")).to route_to controller: "pages", action: "robots", format: "txt"
    end
  end
end
