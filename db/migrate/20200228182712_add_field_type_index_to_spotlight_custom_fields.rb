class AddFieldTypeIndexToSpotlightCustomFields < ActiveRecord::Migration[5.2]
  def change
    add_index(:spotlight_custom_fields, :field_type)
  end
end
