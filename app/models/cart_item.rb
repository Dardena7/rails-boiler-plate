class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  attribute :quantity, :integer

  def total
    product.price * quantity
  end
end
