class AddThumbnailsEnabledToExhibits < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_exhibits, :thumbnails_enabled, :boolean, default: true
  end
end
