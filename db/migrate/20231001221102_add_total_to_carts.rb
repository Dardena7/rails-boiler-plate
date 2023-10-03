class AddTotalToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :total, :decimal, precision: 10, scale: 2, default: 0.00
  end
end
