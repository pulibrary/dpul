require 'rails_helper'

RSpec.describe User do
  subject { FactoryGirl.build(:user) }

  it "uses the username as its stringified value" do
    expect(subject.to_s).to eq subject.username
  end

  describe ".from_omniauth" do
    it "creates a user" do
      token = double("token", provider: "cas", uid: "test")
      user = described_class.from_omniauth(token)
      expect(user).to be_persisted
      expect(user.provider).to eq "cas"
      expect(user.uid).to eq "test"
      expect(user.username).to eq "test"
    end
    it "doesn't make them an administrator" do
      token = double("token", provider: "cas", uid: "test")
      user = described_class.from_omniauth(token)
      expect(user.roles).to eq []
    end
  end
end
