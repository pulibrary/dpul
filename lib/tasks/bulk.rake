# frozen_string_literal: true

require "csv"

namespace :dpul do
  namespace :bulk do
    desc "Import label and description overrides from CSV file"
    task labels: :environment do
      slug = ENV["SLUG"]
      labels_csv = ENV["LABELS_CSV"]
      exhibit = Spotlight::Exhibit.where(slug: slug).first
      raise "Can't find exhibit with slug '#{slug}'" unless exhibit
      raise "Can't find labels CSV file '#{labels_csv}'" unless File.exist?(labels_csv)

      CSV.foreach(labels_csv, headers:true, col_sep: ",") do |row|
        id = row["id"]
        title = row["title"]
        desc = row["description"]
        puts id
        BulkLabeler.run(exhibit: exhibit, id: id, title: title, description: desc)
      end

      Blacklight.default_index.connection.commit
    end
  end
end
