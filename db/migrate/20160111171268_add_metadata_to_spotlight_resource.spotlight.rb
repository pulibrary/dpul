# This migration comes from spotlight (originally 20151110082345)
class AddMetadataToSpotlightResource < ActiveRecord::Migration
  def up
    add_column :spotlight_resources, :metadata, :binary
  end

  def down
    remove_column :spotlight_resources, :metadata
  end
end
