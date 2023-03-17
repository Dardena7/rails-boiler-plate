class AddAuth0IdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :auth0_id, :string
    add_index :users, :auth0_id, unique: true
  end
end
