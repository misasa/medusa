class Api::ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :check_xhr_header, :authenticate, :set_current_user

  
  rescue_from CanCan::AccessDenied, with: :deny_access

  private
  def check_xhr_header
    return if request.xhr?
    render json: { error: 'forbidden' }, status: :forbidden
  end

  def authenticate
    authenticate_by_config if Settings.autologin

    case request.headers["HTTP_AUTHORIZATION"]
    when /^Basic\s+/
      authenticate_by_basic
    when ActionController::HttpAuthentication::Token::TOKEN_REGEX
      authenticate_by_token
    else
      authenticate_user!
    end
  end

  def set_current_user
    User.current = current_user
  end

  def authenticate_by_config
    resource = User.find_by(username: Settings.autologin)
    sign_in :user, resource if resource
  end

  def authenticate_by_basic
    authenticate_or_request_with_http_basic do |name, password|
      resource = User.find_by(username: name)
      sign_in :user, resource if resource.valid_password?(password)
    end
  end

  def authenticate_by_token
    resource = authenticate_or_request_with_http_token do |token, options|
      resource = User.find_by_token(token)
      sign_in :user, resource if resource
    end
  end

end
