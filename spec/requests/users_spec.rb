# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User requests", type: :request do
  let(:token) do
    OpenStruct.new(
      provider: "cas",
      uid: "test"
    )
  end
  let(:params) do
    {
      "omniauth.auth" => token
    }
  end

  describe "#user_cas_omniauth_callback" do
    it "redirects to a login and renders an alert" do
      post "/users/auth/cas/callback", params: params
      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq "Successfully authenticated from CAS account."
    end
  end
end
