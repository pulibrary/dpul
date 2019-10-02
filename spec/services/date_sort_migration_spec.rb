# frozen_string_literal: true

require 'rails_helper'

describe DateSortMigration do
  it "replaces sort_date with ascending and descending, re-weighting if required" do
    FactoryBot.create(:exhibit)
    FactoryBot.create(:exhibit)
    Spotlight::BlacklightConfiguration.all.each do |config|
      config.sort_fields.delete "sort_date_desc"
      config.sort_fields.delete "sort_date_asc"
      config.save
    end
    weighted = Spotlight::BlacklightConfiguration.first
    unweighted = Spotlight::BlacklightConfiguration.last

    # since the sort_date option has been removed, we have to inject it as test
    # setup
    unweighted.sort_fields["sort_date"] = unweighted.sort_fields["sort_title"].deep_dup
    unweighted.sort_fields["sort_date"][:label] = "Date"
    unweighted.save

    weighted.sort_fields["sort_date"] = weighted.sort_fields["sort_title"].deep_dup
    weighted.sort_fields["sort_date"][:label] = "Date"
    weighted.sort_fields["relevance"][:weight] = "-1"
    weighted.sort_fields["sort_title"][:weight] = "0"
    weighted.sort_fields["sort_date"][:weight] = "1"
    weighted.sort_fields["sort_author"][:weight] = "2"
    weighted.save

    described_class.run

    weighted = Spotlight::BlacklightConfiguration.first
    unweighted = Spotlight::BlacklightConfiguration.last

    expect(weighted.sort_fields["sort_date"]).to be_nil
    expect(weighted.sort_fields["sort_date_desc"][:weight]).to eq "1"
    expect(weighted.sort_fields["sort_date_asc"][:weight]).to eq "2"
    expect(weighted.sort_fields["sort_author"][:weight]).to eq "3"

    expect(unweighted.sort_fields["sort_date"]).to be_nil
    expect(unweighted.sort_fields["sort_date_desc"][:weight]).to be_nil
    expect(unweighted.sort_fields["sort_date_asc"][:weight]).to be_nil
  end
end
