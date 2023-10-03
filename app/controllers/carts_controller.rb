require 'active_support/core_ext/hash/keys'

class CartsController < ApplicationController
  include TranslationsUtils
  include FilesUtils
  include ObjectsUtils
  before_action :authorize!

  def index
    locale = request.headers["Accept-Language"]  || I18n.locale

    current_user = User.find_by(auth0_id: @token['sub'])
    cart = current_user.carts.last
    
    cart_items = cart.cart_items.includes(:product)

    cart_items = cart.cart_items.includes(:product).map do |cart_item|
      cart_item.as_json.merge(product: get_product(cart_item.product.id, locale))
    end

    render :json => cart.as_json().merge(cart_items: cart_items)
  end

  def merge_cart
    current_user = User.find_by(auth0_id: @token['sub'])
    cart = current_user.carts.last

    cart_items = params[:cart_items]

    cart_items.each do |cart_item|
      product = Product.find(cart_item[:product_id])
      quantity = cart_item[:quantity].to_i
      cart.add_product(product, quantity)
    end

    render :json => {success: true}.to_json
  end

  def add_to_cart
    current_user = User.find_by(auth0_id: @token['sub'])
    cart = current_user.carts.last

    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    if cart.add_product(product, quantity)
      render :json => {success: true}.to_json
    else
      render :json => {success: false}.to_json
    end
  end

  def update_quantity
    current_user = User.find_by(auth0_id: @token['sub'])
    cart = current_user.carts.last

    product = Product.find(params[:product_id])
    new_quantity = params[:new_quantity].to_i

    if cart.update_quantity(product, new_quantity)
      render :json => {success: true}.to_json
    else
      render :json => {success: false}.to_json
    end
  end

  def remove_from_cart
    current_user = User.find_by(auth0_id: @token['sub'])
    cart = current_user.carts.last

    product = Product.find(params[:product_id])

    if cart.remove_product(product)
      render :json => {success: true}.to_json
    else
      render :json => {success: false}.to_json
    end
  end

end