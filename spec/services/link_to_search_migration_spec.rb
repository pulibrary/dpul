# frozen_string_literal: true

require "rails_helper"

describe LinkToSearchMigration do
  before do
    FactoryBot.create(:exhibit)
    Spotlight::BlacklightConfiguration.all.each do |config|
      config.index_fields["first_field_ssm"] = { "link_to_search" => "first" }
      config.save
    end
  end

  it "replaces the link_to_search field name with link_to_facet" do
    described_class.run

    config = Spotlight::BlacklightConfiguration.all.first
    first_field = config.index_fields["first_field_ssm"]
    expect(first_field["link_to_facet"]).to eq "first"
  end
end
