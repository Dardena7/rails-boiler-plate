class RenameProductsCategoriesToCategoriesProducts < ActiveRecord::Migration[7.0]
  def change
    rename_table :products_categories, :categories_products
  end
end
