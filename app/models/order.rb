class Order < ApplicationRecord
  belongs_to :address
  belongs_to :user, optional: true
  belongs_to :cart
  has_many :order_items, dependent: :destroy
  
  before_create :generate_uuid

  
  def create_order_items
    cart.cart_items.each do |cart_item|
      product = cart_item.product
      quantity = cart_item.quantity
      price = cart_item.product.price
      total = cart_item.total
      order_items.create(product: product, price: price, quantity: quantity, total: total)
    end
  end
  
  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
