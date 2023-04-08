class CreateCategoriesAndJoinProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name
    end

    create_table :products_categories, id: false do |t|
      t.belongs_to :product
      t.belongs_to :category
    end
  end
end
