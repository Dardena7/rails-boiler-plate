class AddUuidToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :uuid, :string, null: true
  end
end
