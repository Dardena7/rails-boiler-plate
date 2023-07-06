class AddForeignKeyConstraintsToCategoriesProducts < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :categories_products, :categories
    add_foreign_key :categories_products, :products
  end
end
