# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'callback response to User object' do
    let(:last_name) { 'LastName' }
    let(:uid) { '12345678901234' }
    let(:omniauth_response) do
      OmniAuth::AuthHash.new(provider: 'barcode', uid: uid, info:
        { last_name: last_name })
    end

    it 'last_name is mapped to username property' do
      expect(User.from_omniauth(omniauth_response).username).to eq uid
    end
    it 'provider property gets set' do
      expect(User.from_omniauth(omniauth_response).provider).to eq 'barcode'
    end
  end
end
