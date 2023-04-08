require 'active_support/core_ext/hash/keys'

class UsersController < ApplicationController
  before_action :authorize!, except: [:create]

  def index
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin()
    users = User.all
    render :json => users.to_json
  end

  def show
    return render :json => {success: false, errors: ["Not authorized"]} unless can_access(params[:id])

    user = User.find_by(auth0_id: params[:id])
    render :json => user.to_json
  end

  def create
    if can_create(request.headers['Authorization'])
      handle_user_creation(params[:params][:user])
    else 
      render :json => {success: false, errors: ["Not authorized"]}.to_json
    end
  end

  def update
    return render :json => {success: false, errors: ["Not authorized"]}.to_json unless can_update(params[:id])

    user = User.find_by(auth0_id: params[:id])

    if !user.present? 
      return render :json => {success: false, errors: ["User not found"]}.to_json
    end

    handle_user_update(user, params)
  end


  private


  def can_access(userId)
    return is_manager() || @token['sub'] == userId
  end

  def can_update(userId)
    return is_admin() || @token['sub'] == userId
  end

  def can_create(authorizationBearer)
    webhookToken = authorizationBearer.split.last if authorizationBearer.present?
    ENV["AUTH0_WEBHOOK_TOKEN"] == webhookToken
  end

  def handle_user_creation(params)
    user = User.new({auth0_id: params[:user_id], email: params[:email]})

    if user.save
      render :json => {success: true, user: user}.to_json
    else
      render :json => {success: false, errors: user.errors}.to_json
    end
  end

  def handle_user_update(user, params)
    update_user_params = update_user_params(params)
    
    if user.update(update_user_params)
      render :json => {success: true, user: user}.to_json
    else
      render :json => {success: false, errors: user.errors}.to_json
    end
  end

  def create_user_params(params)
    params.require(:user).permit(:auth0_id, :email)
  end

  def update_user_params(params)
    params.require(:user).permit(:firstname, :lastname, :terms_and_conditions)
  end

end
