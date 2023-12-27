require 'active_support/core_ext/hash/keys'

class AddressesController < ApplicationController
  before_action :authorize!

  def create
    user = User.find_by(auth0_id: @token['sub'])
    permitted_params = address_params(params)
    address = Address.new(permitted_params[:address])
    address.user = user

    if address.save
      render :json => {success: true, address: address}.to_json
    else
      render :json => {success: false, address: address.errors}
    end
  end

  def update
    user = User.find_by(auth0_id: @token['sub'])
    permitted_params = address_params(params)
    address = Address.find(permitted_params[:address_id])

    return render :json => {success: false, errors: ["Not authorized"]}.to_json unless can_access(address, user)

    address.update(permitted_params[:address])

    if address.save
      render :json => {success: true, address: address}.to_json
    else
      render :json => {success: false, address: address.errors}
    end
  end

  def destroy
    user = User.find_by(auth0_id: @token['sub'])
    address = Address.find(params[:id])

    return render :json => {success: false, errors: ["Not authorized"]}.to_json unless can_access(address, user)

    if address.destroy
      render :json => {success: true}.to_json
    else
      render :json => {success: false}
    end
  end

  private

  def can_access(address, user)
    return is_manager? || address.user == user
  end

  def address_params(params)
    params.permit(:address_id, address: [:complete_name, :city, :street, :country, :zip])
  end
end