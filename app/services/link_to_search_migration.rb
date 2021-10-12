# frozen_string_literal: true

class LinkToSearchMigration
  # Migrates `link_to_facet` field in blacklight configurations to
  # `link_to_search` for compatibility with Blacklight 7.
  def self.run
    Spotlight::BlacklightConfiguration.all.each do |config|
      fields = config.index_fields.select { |_k, v| v["link_to_facet"] }
      fields.keys.each do |key|
        config.index_fields[key]["link_to_search"] = config.index_fields[key].delete("link_to_facet")
      end
      config.save
    end
  end
end
