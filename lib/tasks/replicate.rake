# frozen_string_literal: true

namespace :dpul do
  namespace :replicate do
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

    def replicate_solr(date:)
      date = date.delete("-")
      solr_url, collection = solr_connection_info

      `curl "#{solr_url}/admin/collections?action=DELETE&name=#{collection}"`
      `curl "#{solr_url}/admin/collections?action=RESTORE&name=dpul-production-#{date}.bk&collection=#{collection}&location=/mnt/solr_backup/solr8/production/#{date}"`
    end

    def solr_connection_info
      connection = Blacklight.default_index.connection.uri.to_s
      connection = connection.split("/")
      collection = connection.pop
      [connection.join("/"), collection]
    end

    def dump_postgres(date:)
      dump_connection = connection_string(env: "production")

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
        unzipped_location

      else # get it from the prod database
        filename = "dpul_production_replication_#{date}.sql"
        download_location = File.join(download_dir, filename)

        `pg_dump -Fc #{dump_connection} > #{download_location}`
        download_location
      end
    end

    def load_postgres(dump_file:)
      load_connection = connection_string(env: Rails.env)

      `pg_restore --clean --no-owner -d #{load_connection} #{dump_file}`
    end

    def replicate_uploaded_images
      FileUtils.cp_r('/mnt/shared_data/dpul_production/.', '/mnt/shared_data/dpul_staging')
    end

    # Before running this task turn off nginx and sidekiq-workers on all staging
    # boxes. This prevents existing db connections from creating table entries
    # during restore. After running the task, you may need to clear your browser
    # cache if you see errors.
    desc "Replicate production database, index, and uploaded files to staging"
    task to_staging: :environment do
      # This will break when staging and production are on two different
      # postgres servers. We can fix this in the future if we can make
      # database.yml not use the same env variables for prod, and give the
      # staging machines the prod credential environment variables.
      # Or, we can get the desired dump format on google cloud and pull from there
      abort "this task can only be run on staging" unless Rails.env.staging?

      # Default to today
      date = ENV["DATE"] || Date.current.to_s

      puts "Dumping state of production database"
      dump_file = dump_postgres(date:)

      puts "Loading postgres to staging"
      load_postgres(dump_file:)

      puts "Replicating Solr from production backup."
      replicate_solr(date:)

      puts "Replicating uploaded images from production to staging"
      replicate_uploaded_images
    end

    desc "Dump production database"
    task dump_prod: :environment do
      abort "this task can only be run on staging" unless Rails.env.staging?

      # Default to today
      date = ENV["DATE"] || Date.current.to_s

      puts "Dumping postgres from current production state"
      dump_file = dump_postgres(date:)
      puts "Saved production dump at #{dump_file}"
    end

    desc "Load production database to development. You can generate a dump file by running the dump_prod task on the staging machine, then scp it to your machine."
    task load_db: :environment do
      dump_file = ENV["DUMP_FILE"]
      abort "usage: DUMP_FILE=[filename] rake dpul:replicate:prod:dev" unless dump_file
      abort "this task can only be run in development" unless Rails.env.development?

      puts "Loading postgres to development"
      load_postgres(dump_file:)
    end
  end
end
