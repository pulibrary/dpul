# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:user) { FactoryBot.build(:user) }

  it "uses the username as its stringified value" do
    expect(user.to_s).to eq user.username
  end

  describe ".from_omniauth" do
    context "with a campus user" do
      let(:token) { OmniAuth::AuthHash::InfoHash.new(provider: "cas", uid: "test") }
      let(:user) { described_class.from_omniauth(token) }

      it "creates a persisted user" do
        expect(user).to be_persisted
      end
      it "has a cas provider" do
        expect(user.provider).to eq "cas"
      end
      it "has a uid" do
        expect(user.uid).to eq "test"
      end
      it "has a username" do
        expect(user.username).to eq "test"
      end
      it "creates an email address based on netid" do
        expect(user.email).to eq("test@princeton.edu")
      end
      it "doesn't make them an administrator" do
        expect(user.roles).to eq []
      end
    end

    context "with an external user" do
      let(:token) { OmniAuth::AuthHash::InfoHash.new(provider: "cas", uid: "test@example.com") }
      let(:user) { described_class.from_omniauth(token) }

      it "creates a persisted user" do
        expect(user).to be_persisted
      end
      it "has a cas provider" do
        expect(user.provider).to eq "cas"
      end
      it "has a uid" do
        expect(user.uid).to eq "test@example.com"
      end
      it "has a username" do
        expect(user.username).to eq "test@example.com"
      end
      it "has email equal to uid" do
        expect(user.email).to eq("test@example.com")
      end
      it "doesn't make them an administrator" do
        expect(user.roles).to eq []
      end
      it "can be called twice" do
        user
        described_class.from_omniauth(token)
      end
    end
  end

  describe "inviting users" do
    it "can invite campus users" do
      expect { described_class.invite!(email: 'a-user-that-does-not-exist@princeton.edu', skip_invitation: true) }.not_to raise_error
      expect(described_class.last.provider).to eq "cas"
      expect(described_class.last.uid).to eq "a-user-that-does-not-exist"
      expect(described_class.last.username).to eq "a-user-that-does-not-exist"
      expect(described_class.last.invite_pending?).to eq false
    end

    it "can invite external users" do
      expect { described_class.invite!(email: 'new-user@example.com', skip_invitation: true) }.not_to raise_error
      expect(described_class.last.provider).to eq "cas"
      expect(described_class.last.uid).to eq "new-user@example.com"
      expect(described_class.last.username).to eq "new-user@example.com"
      expect(described_class.last.invite_pending?).to eq false
    end
  end
end
