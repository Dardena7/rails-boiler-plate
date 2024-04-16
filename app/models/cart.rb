class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  attribute :uuid, :string
  attribute :completed, :boolean

  def total
    cart_items.sum(&:total)
  end

  def add_product(product, quantity)
    cart_item = cart_items.find_or_initialize_by(product: product)
    cart_item.quantity ||= 0
    cart_item.quantity += quantity
    cart_item.save
  end

  def update_quantity(product, new_quantity)
    if (new_quantity <= 0) 
      return remove_product(product) 
    end
    
    cart_item = cart_items.find_by(product: product)
    if cart_item
      cart_item.update(quantity: new_quantity)
      true
    else
      false
    end
  end

  def remove_product(product)
    cart_item = cart_items.find_by(product: product)
    if cart_item
      cart_item.destroy
      true
    else
      false
    end
  end

  def verify_cart_total(total)
    errors = {product_inactive: false, total_changed: false}

    cart_items.each do |cart_item|
      product = cart_item.product
      errors[:product_inactive] = true if !product.active
    end
    
    errors[:total_changed] = true if self.total.to_s != total

    return errors
  end
end
