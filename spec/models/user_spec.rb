require 'rails_helper'

RSpec.describe User do
  let(:user) { FactoryBot.build(:user) }

  it "uses the username as its stringified value" do
    expect(user.to_s).to eq user.username
  end

  describe ".from_omniauth" do
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
    it "doesn't make them an administrator" do
      expect(user.roles).to eq []
    end
  end
end
