class AddTotalToCartItems < ActiveRecord::Migration[7.0]
  def change
    add_column :cart_items, :total, :decimal, precision: 10, scale: 2, default: 0.00
  end
end
