# frozen_string_literal: true

# Spotlight assumes that the title field is the field name, but we need it to be
# a Field object so it can fall back to override title. This makes it delegate
# to_s to the field so that autocomplete works.
class FieldStringifier < SimpleDelegator
  def to_s
    __getobj__.field.to_s
  end
end
