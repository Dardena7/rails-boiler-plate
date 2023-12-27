class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  attribute :total, :decimal, precision: 10, scale: 2

  before_save :calculate_total

  def calculate_total
    self.total = quantity * product.price
  end
end
