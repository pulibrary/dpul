require 'rails_helper'

RSpec.describe "exhibit routing" do
  describe "POST /exhibits" do
    it "routes to local exhibits controller" do
      expect(post "/spotlight").to route_to controller: "exhibits", action: "create"
    end
  end
end
