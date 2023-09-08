class AddDeletedToCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :deleted, :boolean, null: false, default: true
  end
end
