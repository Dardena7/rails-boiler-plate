module TranslationsUtils
  extend ActiveSupport::Concern

  def get_translations(object)
    translations = {}
    object.class.mobility_attributes.each do |attribute|
      translations[attribute] = {}
      Mobility.available_locales.each do |locale|
        t = object.send(attribute, locale: locale)
        translations[attribute][locale] = object.send(attribute, locale: locale)
      end
    end
    return translations
  end

  def set_translations(object, params)
    Mobility.available_locales.each do |locale|
      object.class.mobility_attributes.each do |attribute|
        next if !params[attribute].present?
        object.send("#{attribute}=", params[attribute][locale], locale: locale)
      end
    end
  end

end