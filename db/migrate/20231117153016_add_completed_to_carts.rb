class AddCompletedToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :completed, :boolean, default: false
  end
end
