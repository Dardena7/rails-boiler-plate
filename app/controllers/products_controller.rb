require 'active_support/core_ext/hash/keys'

class ProductsController < ApplicationController
  include TranslationsUtils
  include FilesUtils
  before_action :authorize!, only: [:create, :update, :destroy]

  def index
    locale = request.headers["Accept-Language"]  || I18n.locale

    Mobility.with_locale(locale) do
      products = Product.all
      render :json => products.to_json
    end
  end

  def show
    locale = request.headers["Accept-Language"]  || I18n.locale
    render :json => get_product(params[:id], locale)
  end

  def create
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?
    
    product = Product.new
    permitted_params = product_params(params)
    pp "permitted_params: #{permitted_params}"
    handle_product_edition(product, permitted_params)
  end

  def update
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?
    
    product = Product.find(params[:id])
    return render :json => {success: false, errors: ["Product not found"]}.to_json unless product.present?
    
    permitted_params = product_params(params)
    handle_product_edition(product, permitted_params)
  end

  def destroy
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?

    product = Product.find(params[:id])
    return render :json => {success: false, errors: ["Product not found"]}.to_json unless product.present?

    product.delete
    render :json => {success: true}.to_json
  end

  def search
    locale = request.headers["Accept-Language"]  || I18n.locale

    query = params[:query]
    sanitized_query = ActiveRecord::Base.sanitize_sql_like(query)

    connection = ActiveRecord::Base.connection

    sql = <<~SQL
      SELECT DISTINCT translatable_id FROM mobility_string_translations
      WHERE translatable_type = 'Product' AND locale = ? AND value LIKE ?
    SQL

    # Execute a raw SQL query to select all records from a table
    result = connection.exec_query(sql, 'Product search', [locale, "%#{sanitized_query}%"])

    products = []

    result.each do |row|
      product_id = row['translatable_id']
      product = get_product(product_id, locale)
      next if product.nil?

      products.push(get_product(product_id, locale))
    end

    render :json => products.to_json
  end


  private

  def get_product(id, locale)
    Mobility.with_locale(locale) do
      product = Product.find_by_id(id)
      return nil if product.nil? 

      translations = get_translations(product)
      images = get_images(product)
      product.as_json(:include => [:categories]).merge(translations: translations, images: images)
    end
  end

  def handle_product_edition(product, params)
    set_translations(product, params)
    product.categories = Category.where(id: params[:categories]) unless !params.has_key?(:categories)
    update_images(product, params[:image_ids])

    if product.save
      render :json => {success: true, product: product}.to_json
    else
      render :json => {success: false, errors: product.errors}
    end
  end

  def product_params(params)
    params.permit(name: {}, active: true, categories: [], image_ids: [])
  end

  def get_images(product)
    return product.images.map do |image|
      {
        id: image.id,
        url: rails_blob_url(image)
      }
    end
  end

  def update_images(product, image_ids)
    detach_files(product.images, image_ids)
    attach_files(product.images, image_ids)
  end

end
