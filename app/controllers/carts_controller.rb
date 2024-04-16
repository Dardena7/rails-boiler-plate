require 'active_support/core_ext/hash/keys'

class CartsController < ApplicationController
  include TranslationsUtils
  include FilesUtils
  include ObjectsUtils

  def index
    locale = request.headers["Accept-Language"]  || I18n.locale
    cart = get_user_cart()
    render :json => cart.as_json().merge(cart_items: get_cart_items(cart, locale), total: cart.total)
  end

  def add_to_cart
    cart = get_user_cart()

    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    if cart.add_product(product, quantity)
      render :json => {success: true}.to_json
    else
      render :json => {success: false}.to_json
    end
  end

  def update_quantity
    cart = get_user_cart()

    product = Product.find(params[:product_id])
    new_quantity = params[:new_quantity].to_i

    if cart.update_quantity(product, new_quantity)
      render :json => {success: true}.to_json
    else
      render :json => {success: false}.to_json
    end
  end

  def remove_from_cart
    cart = get_user_cart()

    product = Product.find(params[:product_id])

    if cart.remove_product(product)
      render :json => {success: true}.to_json
    else
      render :json => {success: false}.to_json
    end
  end

  private

  def get_user_cart
    return get_guest_cart unless request.headers['Authorization'].present?
    authorize!
    user = User.find_by(auth0_id: @token['sub'])
    cart = Cart.find_by(user_id: user.id, completed: false) || user.carts.create
    merge_cart(cart) if cart.uuid != params[:uuid]
    return cart
  end

  def get_guest_cart
    cart = Cart.find_by(uuid: params[:uuid], completed: false)
    return cart if cart.present?
    Cart.create(uuid: SecureRandom.uuid) 
  end

  def merge_cart(user_cart)
    guest_cart = Cart.find_by(uuid: params[:uuid], completed: false)
    return unless guest_cart.present?

    guest_cart.cart_items.each do |cart_item|
      product = cart_item.product
      quantity = cart_item.quantity
      same_item = user_cart.cart_items.find_by(product: product)
      same_item ? user_cart.update_quantity(product, quantity + same_item.quantity) : user_cart.add_product(product, quantity)
    end

    user_cart.uuid = guest_cart.uuid
    user_cart.save
    guest_cart.destroy
  end
end