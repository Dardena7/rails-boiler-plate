class AddActiveToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :active, :boolean, null: false, default: true
  end
end
