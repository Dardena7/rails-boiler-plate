class AddDefaultToPriceInProducts2 < ActiveRecord::Migration[7.0]
  def change
    # Add the default value of 0.00 for new records
    change_column :products, :price, :decimal, precision: 10, scale: 2, default: 0.00

    # Update existing records to set the price to 0.00
    execute("UPDATE products SET price = 0.00 WHERE price IS NULL")
  end
end
