# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalCollectionsQuery do
  subject(:query) { described_class }
  context "when collections are enabled" do
    before do
      stub_collections(fixture: "collections.json")
    end
    describe ".all" do
      it "queries figgy for all collections" do
        expect(query.all.map(&:slug)).to eq ["princeton-best", "test-collection-2"]
      end
    end

    describe ".uncreated" do
      it "returns collections sorted by title" do
        expect(query.uncreated.map(&:human_label)).to eq ["Test Collection 2", "princeton"]
      end

      it "returns all collections that don't exist already" do
        FactoryBot.create(:exhibit, slug: "princeton-best")

        expect(query.uncreated.map(&:slug)).to eq ["test-collection-2"]
      end
    end
  end
  context "when no collections are returned" do
    before do
      stub_collections(fixture: "no_collections.json")
    end
    it "returns an empty set" do
      expect(query.all).to eq []
    end
  end
end
