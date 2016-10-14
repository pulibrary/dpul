class AddOmniAuthToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :provider, :string
    add_index :users, :provider
    add_column :users, :uid, :string
    add_index :users, :uid
    add_column :users, :username, :string
    add_index :users, :username
  end
end
