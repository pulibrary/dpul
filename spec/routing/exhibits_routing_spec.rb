require 'rails_helper'

RSpec.describe "exhibit routing" do
  describe "POST /exhibits" do
    it "routes to local exhibits controller" do
      expect(post("/")).to route_to controller: "exhibits", action: "create"
    end
  end

  describe "GET /catalog" do
    it "routes to the catalog controller" do
      expect(get("/catalog")).to route_to controller: "catalog", action: "index"
    end
  end

  describe "PATCH /site" do
    it "routes to the site controller" do
      expect(patch("/site")).to route_to controller: "spotlight/sites", action: "update"
    end
  end
end
