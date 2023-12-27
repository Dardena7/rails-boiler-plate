require 'active_support/core_ext/hash/keys'

class OrdersController < ApplicationController
  include ObjectsUtils
  include TranslationsUtils
  include FilesUtils
  before_action :authorize!, only: [:index, :show]

  def index
    user = User.find_by(auth0_id: @token['sub'])
    orders = user.orders.order(id: :desc)
    render :json => orders.as_json(include: :cart)
  end

  def show
    locale = request.headers["Accept-Language"]  || I18n.locale
    order = Order.find_by(id: params[:id])

    return render :json => {success: false, errors: ["Not authorized"]} unless can_access(order.user.auth0_id)

    order_items = get_order_items(order, locale)
    render :json => order.as_json(include: :address).merge(order_items: order_items)
  end

  def order_confirmation
    locale = request.headers["Accept-Language"]  || I18n.locale
    #$$alex todo don't allow to fetch after 1 week/month ?
    order = Order.find_by(uuid: params[:uuid])

    order_items = get_order_items(order, locale)
    render :json => order.as_json(include: :address).merge(order_items: order_items)
  end

  def create
    permitted_params = order_params(params)
    address = Address.create(permitted_params[:address])
    cart = Cart.find(permitted_params[:cart_id])
    user = get_user()

    errors = cart.verify()
    return render :json => {success: false, errors: errors}.to_json, status: :unprocessable_entity if errors[:product_inactive] || errors[:total_changed]

    cart.update(completed: true)
    email = user.present? ? user.email : permitted_params[:email]

    order = Order.create(cart: cart, user: user, email: email, address: address, total: cart.total)
    order.create_order_items()

    render :json => {success: true, order: order}.to_json
  end

  private

  def can_access(userId)
    return is_manager? || @token['sub'] == userId
  end

  def order_params(params)
    params.permit(:cart_id, :email, address: [:complete_name, :city, :street, :country, :zip])
  end

  def get_user
    return nil unless request.headers['Authorization'].present?
    authorize!
    User.find_by(auth0_id: @token['sub'])
  end
end