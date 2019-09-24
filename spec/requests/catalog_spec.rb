require 'rails_helper'

RSpec.describe "catalog paths", type: :request do
  describe "browserconfig.xml" do
    it "routes to the browserconfig static XML asset" do
      get "/browserconfig.xml"

      expect(response.status).to eq 200
      expect(response.body).not_to be_empty
      expect(response.content_type).to eq "application/xml"
    end
  end
  describe "Apple touch icons" do
    it "routes to the static PNG assets" do
      get "/apple-touch-icon.png"

      expect(response.status).to eq 200
      expect(response.body).not_to be_empty
      get "/apple-touch-icon-precomposed.png"

      expect(response.status).to eq 200
      expect(response.body).not_to be_empty
      get "/apple-touch-icon-120x120.png"

      expect(response.status).to eq 200
      expect(response.body).not_to be_empty
      get "/apple-touch-icon-120x120-precomposed.png"

      expect(response.status).to eq 200
      expect(response.body).not_to be_empty
    end
  end
  describe "wp-login.php" do
    it "redirects to the catalog index" do
      get "/wp-login.php"
      expect(response.status).to eq 404
    end
  end
  describe "catalog item" do
    context "when the item does not exist" do
      it "returns a 404 status code response" do
        get "/catalog/no-exist"
        expect(response.status).to eq 404
      end

      it "returns a 404 status code response for JSON views" do
        get "/catalog/no-exist", params: { format: :json }
        expect(response.status).to eq 404
      end
    end
  end
end
