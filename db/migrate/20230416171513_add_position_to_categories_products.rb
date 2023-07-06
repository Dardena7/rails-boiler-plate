class AddPositionToCategoriesProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :categories_products, :position, :integer
  end
end
