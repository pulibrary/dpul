# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "unmatched routes" do
    before do
      get "/nonexistent_resource"
    end

    it "has an http status of 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "redirects to the custom not_found error page" do
      expect(response.body).to include("The page you requested doesn't exist")
    end
  end

  # Blacklight::Exceptions::RecordNotFound
  describe "record not found" do
    it "renders a 404 page" do
      params = { id: "unknown_work" }
      get "/catalog/#{params[:id]}"

      expect(response.status).to eq(404)
      expect(response.body).to include("The page you requested doesn't exist")
    end
  end

  describe "json requests for the main page" do
    it "returns a 404 status code response" do
      get "/", params: { format: :json }
      expect(response.status).to eq 404
    end
  end
end