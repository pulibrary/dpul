# frozen_string_literal: true

require 'rails_helper'

describe AllFieldsLabelMigration do
  # since code is changed; newly-generated exhibits will get the correct label;
  # set them to the old label so we can test.
  before do
    FactoryBot.create(:exhibit)
    FactoryBot.create(:exhibit)
    Spotlight::BlacklightConfiguration.all.each do |bc|
      bc.search_fields["all_fields"][:label] = "Everything"
      bc.save
    end
  end

  it "changes the label for all_fields search field from Everything to Keyword" do
    expect(exhibit_configs.flatten.uniq).to eq ["Everything"]
    expect(browse_configs.flatten.uniq).to eq ["Everything"]
    described_class.run
    expect(exhibit_configs.flatten.uniq).to eq ["Keyword"]
    expect(browse_configs.flatten.uniq).to eq ["Keyword"]
  end

  def exhibit_configs
    Spotlight::Exhibit.all.to_a.map { |e| e.blacklight_config.search_fields["all_fields"][:label] }
  end

  def browse_configs
    Spotlight::Exhibit.all.to_a.map { |e| e.searches.first.blacklight_config.search_fields["all_fields"][:label] }
  end
end
