class TaggableIdInteger < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      change_column :taggings, :taggable_id, 'integer USING CAST("taggable_id" AS integer)'
    else
      change_column :taggings, :taggable_id, :integer
    end
  end

  def down
    change_column :taggings, :taggable_id, :string
  end
end
