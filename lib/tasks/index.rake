# frozen_string_literal: true

namespace :reindex do
  desc 'Reindex all collections'
  task collections: :environment do
    Spotlight::Exhibit.all.each do |exhibit|
      puts "Queuing reindex for #{exhibit.slug}: #{exhibit.title}"
      Spotlight::ReindexJob.perform_later(exhibit)
    end
  end
end
