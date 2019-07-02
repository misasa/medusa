# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :adjust_url_by_requesting_tab

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate, :set_current_user
  before_action :set_searchable_records, if: Proc.new {|controller| controller.current_user }
  before_action :set_alias_specimen
  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied, with: :deny_access

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

  def format_html_or_signed_in?
    request.format.html? || user_signed_in?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
  
  def set_current_user
    User.current = current_user
  end

  def set_searchable_records
    @records_search = RecordProperty.search
  end

  def adjust_url_by_requesting_tab(url)
    return url if params[:tab].blank?
    work_url = url.sub(/tab=.*&/,"").sub(/\?tab=.*/,"")
    work_url + (work_url.include?("?") ? "&" : "?") + "tab=#{params[:tab]}"
  end

  protected

  def verified_request?
    # REST-API対応のため、主要ブラウザ以外はcsrf-tokenをチェックしない
    super || request.user_agent !~ /^(Mozilla|Opera)/
  end

  private
  
  def deny_access
    respond_to do |format|
      format.html { render "parts/access_denied", status: :forbidden }
      format.all { render nothing: true, status: :forbidden }
    end
  end

  def set_alias_specimen
    @alias_specimen = Settings.specimen_name
    @alias_specimens = @alias_specimen.pluralize
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
