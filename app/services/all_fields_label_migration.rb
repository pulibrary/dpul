# frozen_string_literal: true

class AllFieldsLabelMigration
  def self.run
    Spotlight::BlacklightConfiguration.all.each do |bc|
      bc.search_fields["all_fields"][:label] = "Keyword"
      bc.save
    end
  end
end
