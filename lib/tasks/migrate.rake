# frozen_string_literal: true

namespace :dpul do
  namespace :migrate do
    desc "Migrate date sort fields"
    task date_sort: :environment do
      DateSortMigration.run
    end

    desc "Migrate all_fields search field label from Everything to Keyword"
    task all_fields_label: :environment do
      AllFieldsLabelMigration.run
    end
  end
end
