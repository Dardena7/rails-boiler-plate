class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  attribute :total, :decimal, precision: 10, scale: 2
  attribute :uuid, :string
  attribute :completed, :boolean

  def add_product(product, quantity)
    cart_item = cart_items.find_or_initialize_by(product: product)
    cart_item.quantity ||= 0
    cart_item.quantity += quantity
    cart_item.save
    update_total()
  end

  def update_quantity(product, new_quantity)
    if (new_quantity <= 0) 
      return remove_product(product) 
    end
    
    cart_item = cart_items.find_by(product: product)
    if cart_item
      cart_item.update(quantity: new_quantity)
      update_total()
      true
    else
      false
    end
  end

  def remove_product(product)
    cart_item = cart_items.find_by(product: product)
    if cart_item
      cart_item.destroy
      update_total()
      true
    else
      false
    end
  end

  def update_total
    new_total = cart_items.sum { |item| item.total }
    update(total: new_total)
  end

  def verify
    errors = {product_inactive: false, total_changed: false}
    current_total = total

    cart_items.each do |cart_item|
      product = cart_item.product
      errors[:product_inactive] = true if !product.active
      cart_item.save
    end
    
    update_total()

    new_total = total
    errors[:total_changed] = true if current_total != new_total

    return errors
  end
end
