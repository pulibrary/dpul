# frozen_string_literal: true

namespace :dpul do
  namespace :replicate do
    desc "Replicate production database and index to staging"
    task prod: :environment do
      abort "this task can only be run on staging" unless RAILS_ENV.staging?

      date = ENV["DATE"]
      abort "usage: DATE=YYYY-MM-DD" unless date

      db_conf = Rails.configuration.database_configuration[Rails.env]
      host = db_conf["host"]
      port = db_conf["port"]
      username = db_conf["username"]
      password = db_conf["password"]
      userspec = password ? "#{username}:#{password}" : username
      connection_str_base = "postgresql://#{userspec}@#{host}:#{port}"

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

        prod_db = "dpul_production"
        prod_connection = "#{connection_str_base}/#{prod_db}"

        `pg_dump -Fc #{prod_connection} > #{download_location}`
        unzipped_location = download_location
      end

      # restore it to the staging database
      staging_db = db_conf["database"]
      staging_connection = "#{connection_str_base}/#{staging_db}"

      `pg_restore --clean --no-owner -d #{staging_connection} #{unzipped_location}`
    end
  end
end
