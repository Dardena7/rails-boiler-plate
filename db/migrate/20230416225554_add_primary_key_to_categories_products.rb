class AddPrimaryKeyToCategoriesProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :categories_products, :id, :primary_key
  end
end
