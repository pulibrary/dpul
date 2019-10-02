# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  let(:controller) { described_class.new }
  describe "authentication helper methods" do
    it "generates unique guest usernames" do
      expect(controller.guest_username_authentication_key('guest')).to eq 'guest'
      expect(controller.guest_username_authentication_key('fred')).to start_with 'guest_'
    end

    context "creating user objects" do
      let(:user) { controller.create_guest_user }

      after do
        user.destroy
      end

      it "creates guest user objects" do
        expect(user.username).to start_with('guest_')
      end
    end
  end
end
