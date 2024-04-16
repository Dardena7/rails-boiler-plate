module ObjectsUtils
  extend ActiveSupport::Concern

  def get_product(id, locale, show_inactive = false)
    Mobility.with_locale(locale) do
      product = show_inactive ? Product.find_by_id(id) : Product.active.find_by_id(id);
      return nil if product.nil? 

      translations = get_translations(product)
      images = get_images(product)
      product.as_json(:include => [:categories]).merge(translations: translations, images: images)
    end
  end

  def get_cart_items(cart, locale)
    cart.cart_items.includes(:product).map do |cart_item|
      cart_item.as_json.merge(product: get_product(cart_item.product.id, locale, true), total: cart_item.total)
    end
  end

  def get_order_items(order, locale)
    order.order_items.includes(:product).map do |order_item|
      order_item.as_json.merge(product: get_product(order_item.product.id, locale, true))
    end
  end

  private

  def get_images(object)
    return object.images.map do |image|
      {
        id: image.id,
        url: rails_blob_url(image)
      }
    end
  end
    
end