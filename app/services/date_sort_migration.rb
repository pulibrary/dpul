# frozen_string_literal: true

class DateSortMigration
  def self.run
    Spotlight::Exhibit.all.each do |exhibit|
      exhibit_config = Spotlight::BlacklightConfiguration.where(exhibit: exhibit.id).first
      sort_fields = exhibit_config.sort_fields
      next unless sort_fields.keys.include? "sort_date"
      sort_fields["sort_date_desc"] = sort_fields["sort_date"].deep_dup
      sort_fields["sort_date_desc"][:label] = "Date Descending"
      sort_fields["sort_date_asc"] = sort_fields["sort_date"].deep_dup
      sort_fields["sort_date_asc"][:label] = "Date Ascending"
      sort_fields.delete("sort_date")
      exhibit_config.sort_fields = re_weight(sort_fields, bump: "sort_date_asc")
      exhibit_config.save
    end
  end

  # If the sort fields have been ordered in the config UI they each have a
  # sequential "weight" value, encoding their position in the dropdown.
  # Adjust these to insert the 2nd date value with the other date sort,
  # maintaining relative order otherwise
  def self.re_weight(fields, bump:)
    return fields unless fields[bump].keys.map(&:to_sym).include?(:weight)
    weight = fields[bump][:weight]
    new_weight = (weight.to_i + 1).to_s
    next_bump = fields.find do |_field_key, field_config|
      field_config[:weight] == new_weight
    end&.first
    fields[bump][:weight] = new_weight
    fields = re_weight(fields, bump: next_bump) if next_bump
    fields
  end
end
