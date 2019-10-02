# frozen_string_literal: true

namespace :migrate do
  desc "Migrate date sort fields"
  task date_sort: :environment do
    DateSortMigration.run
  end
end
