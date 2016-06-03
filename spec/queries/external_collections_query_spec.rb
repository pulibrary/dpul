require 'rails_helper'

RSpec.describe ExternalCollectionsQuery, vcr: { cassette_name: "all_collections" } do
  subject { described_class }
  describe ".all" do
    it "queries plum for all collections" do
      expect(subject.all.map(&:slug)).to eq ["princeton-best", "test-collection-2"]
    end
  end
  context "when no collections are returned", vcr: { cassette_name: "no_collections", record: :new_episodes } do
    it "returns an empty set" do
      expect(subject.all).to eq []
    end
  end

  describe ".uncreated" do
    it "returns all collections that don't exist already" do
      FactoryGirl.create(:exhibit, slug: "princeton-best")

      expect(subject.uncreated.map(&:slug)).to eq ["test-collection-2"]
    end
  end
end
