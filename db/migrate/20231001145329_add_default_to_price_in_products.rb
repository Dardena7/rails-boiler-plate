class AddDefaultToPriceInProducts < ActiveRecord::Migration[7.0]
  def change
    change_column :products, :price, :decimal, precision: 10, scale: 2, default: 0.00
  end
end
