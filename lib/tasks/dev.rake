# frozen_string_literal: true
if Rails.env.development? || Rails.env.test?
  require "factory_bot"

  namespace :pomegranate do
    desc 'Reindex a resource from a IIIF Manifest URL within an Exhibit'
    task :reindex, %i[manifest exhibit] => [:environment] do |_t, args|
      manifest = args[:manifest]
      exhibit_slug = args[:exhibit]
      exhibit = Spotlight::Exhibit.find_by(slug: exhibit_slug)
      iiif_resource = IIIFResource.find_by(url: manifest, exhibit: exhibit)
      iiif_resource.save_and_index_now
      puts "Reindexed the document for #{manifest}"
    end

    desc 'Clear the SolrDocumentSidecar reference fields'
    task :sidecar_clean_references, [:exhibit] => [:environment] do |_t, args|
      exhibit_slug = args[:exhibit]
      exhibit = Spotlight::Exhibit.find_by(slug: exhibit_slug)
      sidecars = Spotlight::SolrDocumentSidecar.where(exhibit: exhibit)
      sidecars.each do |sidecar|
        sidecar.data
        valid_data = sidecar.data.reject do |k, v|
          k.include?('references') && v.include?('iiif_manifest_paths')
        end
        next unless sidecar.data != valid_data

        sidecar.data = valid_data
        sidecar.save
        sidecar.resource.reindex_later
        puts "Updated the SolrDocumentSidecar for #{sidecar.document_id}"
      end
    end

    desc 'Make first user a site admin'
    task site_admin: :environment do
      user = User.first
      user.roles.create role: 'admin', resource: Spotlight::Site.instance
      puts "Made #{user} a site admin!"
    end

    desc "Start solr server for testing."
    task :test do
      shared_solr_opts = { managed: true, verbose: true, persist: false, download_dir: 'tmp' }
      shared_solr_opts[:version] = ENV['SOLR_VERSION'] if ENV['SOLR_VERSION']

      SolrWrapper.wrap(shared_solr_opts.merge(port: 8984, instance_dir: 'tmp/blacklight-core-test')) do |solr|
        solr.with_collection(name: "blacklight-core-test", dir: Rails.root.join("solr", "config").to_s) do
          puts "Solr running at http://localhost:8984/solr/blacklight-core-test/, ^C to exit"
          begin
            sleep
          rescue Interrupt
            puts "\nShutting down..."
          end
        end
      end
    end

    desc "Start solr server for development."
    task :development do
      SolrWrapper.wrap(managed: true, verbose: true, port: 8983, instance_dir: 'tmp/blacklight-core', persist: true, download_dir: 'tmp') do |solr|
        solr.with_collection(name: "blacklight-core", dir: Rails.root.join("solr", "config").to_s) do
          puts "Setup solr"
          puts "Solr running at http://localhost:8983/solr/blacklight-core/, ^C to exit"
          begin
            if ENV['ENABLE_RAILS']
              # If HOST specified, bind to that IP with -b
              server_options = " -b #{ENV['HOST']}" if ENV['HOST']
              IO.popen("rails server#{server_options}") do |io|
                io.each do |line|
                  puts line
                end
              end
            else
              sleep
            end
          rescue Interrupt
            puts "\nShutting down..."
          end
        end
      end
    end
  end

  namespace :clean do
    namespace :test do
      desc "Cleanup test servers"
      task :solr do
        SolrWrapper.instance(managed: true, verbose: true, port: 8984, instance_dir: 'tmp/blacklight-core-test', persist: false).remove_instance_dir!
        puts "Cleaned up test solr server."
      end
    end

    namespace :development do
      desc "Delete development database and index data"
      task all: :environment do
        Blacklight.default_index.connection.delete_by_query("*:*", params: { softCommit: true })
        Rake::Task['db:reset'].invoke
      end
    end
  end
end
