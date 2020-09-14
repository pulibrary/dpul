# frozen_string_literal: true

namespace :reindex do
  desc 'Reindex all collections'
  task collections: :environment do
    Spotlight::Exhibit.all.each do |exhibit|
      puts "Queuing reindex for #{exhibit.slug}: #{exhibit.title}"
      Spotlight::ReindexJob.perform_later(exhibit)
    end
  end

  desc 'Reindex a resource from a IIIF Manifest URL within an Exhibit'
  task :manifest, %i[manifest exhibit] => [:environment] do |_t, args|
    manifest = args[:manifest]
    exhibit_slug = args[:exhibit]
    exhibit = Spotlight::Exhibit.find_by(slug: exhibit_slug)
    iiif_resource = IIIFResource.find_by(url: manifest, exhibit: exhibit)
    iiif_resource.save_and_index_now
    puts "Reindexed the document for #{manifest}"
  end
end

namespace :index do
  desc 'Commit the index'
  task commit: :environment do
    Blacklight.default_index.connection.commit
  end
end
