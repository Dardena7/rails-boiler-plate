module ObjectsUtils
  extend ActiveSupport::Concern

  def get_product(id, locale)
    Mobility.with_locale(locale) do
      product = Product.find_by_id(id)
      return nil if product.nil? 

      translations = get_translations(product)
      images = get_images(product)
      product.as_json(:include => [:categories]).merge(translations: translations, images: images)
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