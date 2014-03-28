class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :adjust_url_by_requesting_tab

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, :set_current_user
  before_action :set_searchable_records, if: Proc.new {|controller| controller.current_user }
  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
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

end
