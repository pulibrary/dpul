# frozen_string_literal: true

require 'rails_helper'

describe LinkToSearchMigration do
  before do
    FactoryBot.create(:exhibit)
    Spotlight::BlacklightConfiguration.all.each do |config|
      config.index_fields["first_field_ssm"] = { "link_to_facet" => "first" }
      config.save
    end
  end

  it 'replaces the link_to_facet field name with link_to_search' do
    described_class.run

    config = Spotlight::BlacklightConfiguration.all.first
    first_field = config.index_fields["first_field_ssm"]
    expect(first_field["link_to_search"]).to eq "first"
  end
end
