require 'active_support/core_ext/hash/keys'

class CategoriesController < ApplicationController
  include TranslationsUtils
  include FilesUtils
  before_action :authorize!, except: [:index, :show]

  def index
    locale = request.headers["Accept-Language"]  || I18n.locale

    Mobility.with_locale(locale) do
      categories = Category.all
      render :json => categories.to_json
    end
  end

  def show
    locale = request.headers["Accept-Language"]  || I18n.locale

    Mobility.with_locale(locale) do
      category = Category.find(params[:id])
      translations = get_translations(category)
      images = get_images(category)

      render :json => category.as_json(:include => [:products]).merge(translations: translations, images: images)
    end
  end

  def create
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?
    
    category = Category.new
    permitted_params = category_params(params)
    handle_category_edition(category, permitted_params)
  end

  def destroy
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?

    category = Category.find(params[:id])
    return render :json => {success: false, errors: ["Category not found"]}.to_json unless category.present?

    category.delete
    render :json => {success: true}.to_json
  end

  def update
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?
    
    category = find_category(params[:id])
    return category_not_found() unless category.present?
    permitted_params = category_params(params)
    handle_category_edition(category, permitted_params)
  end

  def add_product
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?
    
    category = find_category(params[:category_id])
    return category_not_found() unless category.present?

    product = find_product(params[:product_id])
    return product_not_found() unless product.present?
    
    category_product = find_category_product(category.id, product.id)
    return product_already_present() if category_product.present?
    
    category.products.push(product)

    category_product = find_category_product(category.id, product.id)
    return category_product_not_found() unless category_product.present?

    category_product.move_to_top

    render :json => {success: true}.to_json
  end

  def remove_product
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?

    category_product = find_category_product(params[:category_id], params[:product_id])
    return category_product_not_found() unless category_product.present?

    category_product.remove_from_list
    category_product.delete()

    render :json => {success: true}.to_json
  end

  def move_product
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?

    category_product = find_category_product(params[:category_id], params[:product_id])
    return category_product_not_found() unless category_product.present?

    category_product.insert_at(params[:position])

    render :json => {success: true}.to_json
  end

  def move_category
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?

    category = find_category(params[:category_id])
    return category_not_found() unless category.present?

    category.insert_at(params[:position])

    render :json => {success: true}.to_json
  end


  private

  def find_category(category_id)
    return Category.find(category_id)
  end

  def category_not_found()
    return render :json => {success: false, errors: ["Category not found"]}.to_json
  end

  def find_product(product_id)
    return Product.find(product_id)
  end

  def product_not_found()
    return render :json => {success: false, errors: ["Product not found"]}.to_json
  end

  def find_category_product(category_id, product_id)
    return CategoryProduct.find_by(category_id: category_id, product_id: product_id)
  end

  def category_product_not_found()
    return render :json => {success: false, errors: ["CategoryProduct not found"]}.to_json
  end

  def product_already_present()
    return render :json => {success: false, errors: ["Product is already in this category"]}.to_json
  end

  def handle_category_edition(category, params)
    set_translations(category, params)
    update_images(category, params[:image_ids]) unless !params.has_key?(:image_ids)
    category.active = params[:active] unless !params.has_key?(:active)

    if category.save
      render :json => {success: true, category: category}.to_json
    else
      render :json => {success: false, errors: category.errors}
    end
  end

  def category_params(params)
    params.permit(:active, name: {}, image_ids: [])
  end

  def get_images(category)
    return category.images.map do |image|
      {
        id: category.id,
        url: rails_blob_url(image)
      }
    end
  end

  def update_images(category, image_ids)
    detach_files(category.images, image_ids)
    attach_files(category.images, image_ids)
  end

end
