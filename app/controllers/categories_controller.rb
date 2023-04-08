require 'active_support/core_ext/hash/keys'

class CategoriesController < ApplicationController
  include Translations
  before_action :authorize!, only: [:create, :update]

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

      render :json => category.as_json(:include => [:products]).merge(translations: translations)
    end
  end

  def create
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin()
    
    category = Category.new
    permitted_params = category_params(params)
    handle_category_edition(category, permitted_params)
  end

  def update
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin()
    
    category = Category.find(params[:id])
    return render :json => {success: false, errors: ["Category not found"]}.to_json unless category.present?
    
    permitted_params = category_params(params)
    handle_category_edition(category, permitted_params)
  end


  private

  def handle_category_edition(category, params)
    set_translations(category, params)

    if category.save
      render :json => {success: true, category: category}.to_json
    else
      render :json => {success: false, errors: category.errors}
    end
  end

  def category_params(params)
    params.require(:category).permit(name: {})
  end

end
