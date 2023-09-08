class AddActiveToCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :active, :boolean, null: false, default: true
  end
end
