# frozen_string_literal: true

namespace :dpul do
  namespace :replicate do
    desc "Replicate production database and index to staging"

    # @return [String] Connection string for postgres for the given environment.
    def connection_string(env:)
      db_conf = Rails.configuration.database_configuration[env]
      host = db_conf["host"]
      port = db_conf["port"] || 5432
      username = db_conf["username"]
      password = db_conf["password"]
      userspec = password ? "#{username}:#{password}" : username
      db_name = env.to_sym == :production ? "dpul_production" : db_conf["database"]
      "postgresql://#{userspec}@#{host}:#{port}/#{db_name}"
    end

    task prod: :environment do
      abort "this task can only be run on staging" unless Rails.env.staging?

      # Default to today
      date = ENV["DATE"] || Date.current.to_s

      restore_postgres(date: date)
      restore_solr(date: date)
    end

    def restore_solr(date:)
      date = date.delete("-")

      solr_url, collection = solr_connection_info
      `curl "#{solr_url}/admin/collections?action=DELETE&name=#{collection}"`
      `curl "#{solr_url}/admin/collections?action=RESTORE&name=dpul-production-#{date}.bk&collection=#{collection}&location=/mnt/solr_backup/solr7/production/#{date}"`
    end

    def solr_connection_info
      connection = Blacklight.default_index.connection.uri.to_s
      connection = connection.split("/")
      collection = connection.pop
      [connection.join("/"), collection]
    end

    def restore_postgres(date:)
      # This will break when staging and production are on two different
      # postgres servers.
      dump_connection = connection_string(env: "production")
      restore_connection = connection_string(env: Rails.env)

      download_from_cloud = false
      download_dir = Rails.root.join("tmp")

      if download_from_cloud
        # get the db file
        require "google/cloud/storage"

        storage = Google::Cloud::Storage.new(
          project_id: "pul-gcdc",
          credentials: ENV["GOOGLE_CLOUD_CREDENTIALS"]
        )

        bucket = storage.bucket("pul-postgresql-backup")
        dir = "daily/dpul_production"
        files = bucket.files(prefix: dir)
        filename = files.select { |fn| fn.include?(date) }
        file = bucket.file("#{dir}/#{filename}")
        file.download(Rails.root.join("tmp"))
        download_location = File.join(download_dir, filename)
        # unzip it
        `bunzip2 #{download_location}` # this takes a minute
        unzipped_location = download_location[0..-5] # strip `.bz2`
      else # get it from the prod database
        filename = "dpul_production_replication_#{date}.sql"
        download_location = File.join(download_dir, filename)

        `pg_dump -Fc #{dump_connection} > #{download_location}`
        unzipped_location = download_location
      end

      `pg_restore --clean --no-owner -d #{restore_connection} #{unzipped_location}`
    end
  end
end
