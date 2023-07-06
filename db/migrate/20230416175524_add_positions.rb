class AddPositions < ActiveRecord::Migration[7.0]
  def change
    Category.all.each do |category|
      category.products do |product, index|
        category_product = CategoryProduct.where(product_id: product.id, category_id: category.id)
        category_product.position = index
        category_product.save
      end
    end
  end
end
