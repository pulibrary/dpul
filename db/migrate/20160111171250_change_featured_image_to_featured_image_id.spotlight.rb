# This migration comes from spotlight (originally 20140401232956)
class ChangeFeaturedImageToFeaturedImageId < ActiveRecord::Migration
  def change
    remove_column :spotlight_searches, :featured_image, :string
    add_column :spotlight_searches, :featured_item_id, :string
  end
end
