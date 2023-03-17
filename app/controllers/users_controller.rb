require 'active_support/core_ext/hash/keys'

class UsersController < ApplicationController
  before_action :authorize!, except: [:create]

  def index
    return render :json => {success: false, errors: "Not authorized"} unless isAdmin()
    users = User.all
    render :json => users.to_json.camelize
  end

  def show
    return render :json => {success: false, errors: "Not authorized"} unless canAccess(params[:id])

    user = User.find_by(auth0_id: params[:id])
    render :json => user.to_json.camelize
  end

  def create
    if canCreateUser(request.headers['Authorization'])
      handleUserCreation(params[:params][:user])
    else 
      render :json => {success: true, user: user}.to_json.camelize
    end
  end

  def update
    return render :json => {success: false, errors: "Not authorized"} unless canUpdate(params[:id])

    user = User.find_by(auth0_id: params[:id])

    if !user.present? 
      return render :json => {success: false, errors: "User not found"}
    end

    handleUserUpdate(user, params)
  end


  private


  def canAccess(userId)
    return isManager() || @token['sub'] == userId
  end

  def canUpdate(userId)
    return isAdmin() || @token['sub'] == userId
  end

  def canCreateUser(authorizationBearer)
    webhookToken = authorizationBearer.split.last if authorizationBearer.present?
    ENV["AUTH0_WEBHOOK_TOKEN"] == webhookToken
  end

  def handleUserCreation(params)
    user = User.new({auth0_id: params[:user_id], email: params[:email]})

    if user.save
      render :json => {success: true, user: user}.to_json.camelize
    else
      render :json => {success: false, errors: user.errors}
    end
  end

  def handleUserUpdate(user, params)
    user.firstname = params[:firstname] if params[:firstname].present?
    user.lastname = params[:lastname] if params[:lastname].present?
    user.terms_and_conditions = params[:termsAndConditions] if params[:termsAndConditions].present?
    
    if user.save
      render :json => {success: true, user: user}.to_json.camelize
    else
      render :json => {success: false, errors: user.errors}
    end
  end

end
