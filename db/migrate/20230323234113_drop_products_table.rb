class DropProductsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :products_tables
    create_table :products do |t|
      t.string :name
    end
  end
end
