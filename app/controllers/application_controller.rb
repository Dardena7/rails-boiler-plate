require 'json_web_token'

class ApplicationController < ActionController::API
  def authorize!
    valid, result = verify(raw_token(request.headers))
    render json: { message: result }.to_json, status: :unauthorized unless valid
    @token ||= result
  end

  def is_super_admin
    roles = @token['http://boiler-plate-api.com/roles'] & ["superadmin"]
    return roles.any?
  end

  def is_admin
    roles = @token['http://boiler-plate-api.com/roles'] & ["superadmin", "admin"]
    return roles.any?
  end

  def is_manager
    roles = @token['http://boiler-plate-api.com/roles'] & ["superadmin", "admin", "manager"]
    return roles.any?
  end

  private

  def verify(token)
    payload, = JsonWebToken.verify(token)
    [true, payload]
  rescue JWT::DecodeError => e
    [false, e]
  end

  def raw_token(headers)
    return headers['Authorization'].split.last if headers['Authorization'].present?

    nil
  end

end
