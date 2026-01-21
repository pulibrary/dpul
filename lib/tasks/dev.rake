# frozen_string_literal: true
if Rails.env.development? || Rails.env.test? || Rails.env.staging?
  namespace :dpul do
    namespace :delete do
      desc "Delete all exhibits"
      task exhibits: :environment do
        Spotlight::Exhibit.all.each(&:destroy)
      end
    end
  end
end

if Rails.env.development? || Rails.env.test?
  require "factory_bot"

  namespace :servers do
    desc "Start solr and postgres servers using lando."
    task start: :environment do
      system("lando start")
      system("rake db:create")
      system("rake db:migrate")
      system("rake db:migrate RAILS_ENV=test")
    end

    desc "Stop lando solr and postgres servers."
    task stop: :environment do
      system("lando stop")
    end
  end

  namespace :dpul do
    desc "Make first user a site admin"
    task site_admin: :environment do
      user = User.first
      user.roles.create role: "admin", resource: Spotlight::Site.instance
      puts "Made #{user} a site admin!"
    end
  end

  namespace :clean do
    desc "Clear the SolrDocumentSidecar reference fields"
    task :sidecar_references, [:exhibit] => [:environment] do |_t, args|
      exhibit_slug = args[:exhibit]
      exhibit = Spotlight::Exhibit.find_by(slug: exhibit_slug)
      sidecars = Spotlight::SolrDocumentSidecar.where(exhibit:)
      sidecars.each do |sidecar|
        sidecar.data
        valid_data = sidecar.data.reject do |k, v|
          k.include?("references") && v.include?("iiif_manifest_paths")
        end
        next unless sidecar.data != valid_data

        sidecar.data = valid_data
        sidecar.save
        sidecar.resource.reindex_later
        puts "Updated the SolrDocumentSidecar for #{sidecar.document_id}"
      end
    end

    namespace :development do
      desc "Delete development database and index data"
      task all: :environment do
        Blacklight.default_index.connection.delete_by_query("*:*", params: { softCommit: true })
        Rake::Task["db:reset"].invoke
      end
    end
  end
end
