class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  attribute :total, :decimal, precision: 10, scale: 2

  before_save :calculate_total
  after_save :update_cart_total
  after_destroy :update_cart_total

  def calculate_total
    self.total = quantity * product.price
  end

  private

  def update_cart_total
    cart.calculate_total
  end

end
