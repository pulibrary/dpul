class AddCondensedViewerToExhibits < ActiveRecord::Migration[5.2]
  def change
    add_column :spotlight_exhibits, :condensed_viewer, :boolean, default: false
  end
end
