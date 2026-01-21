# frozen_string_literal: true

namespace :dpul do
  namespace :reindex do
    desc "Reindex all collections"
    task collections: :environment do
      Spotlight::Exhibit.all.each do |exhibit|
        puts "Queuing reindex for #{exhibit.slug}: #{exhibit.title}"
        Spotlight::ReindexJob.perform_later(exhibit)
      end
    end

    desc "Index or reindex a resource from a IIIF Manifest URL within an Exhibit"
    task :manifest, %i[manifest exhibit] => [:environment] do |_t, args|
      manifest = args[:manifest]
      exhibit_slug = args[:exhibit]
      exhibit = Spotlight::Exhibit.find_by(slug: exhibit_slug)
      iiif_resource = IiifResource.find_or_initialize_by(url: manifest, exhibit:)
      iiif_resource.save_and_index_now
      puts "Reindexed the document for #{manifest}"
    end

    desc "Reindex a resource from a noid and Exhibit"
    task :noid, %i[noid exhibit] => [:environment] do |_t, args|
      noid = args[:noid]
      exhibit_slug = args[:exhibit]
      config = CatalogController.blacklight_config
      repo = FriendlyIdRepository.new(config)
      exhibit = Spotlight::Exhibit.find_by(slug: exhibit_slug)
      docs = repo.search(q: "access_identifier_ssim:#{noid}")["response"]["docs"]
      resources = docs.map { |doc| Spotlight::Resource.find(doc["spotlight_resource_id_ssim"].first.split("/").last) }
      iiif_resource = resources.find { |r| r.exhibit_id == exhibit.id }
      iiif_resource.save_and_index_now
      puts "Reindexed the document for #{noid}"
    end
  end

  namespace :index do
    desc "Commit the index"
    task commit: :environment do
      Blacklight.default_index.connection.commit
    end
  end
end
