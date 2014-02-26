class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, :set_current_user, :set_searchable_records
  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  skip_before_filter :verify_authenticity_token # allow CSRF

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
  
  def set_current_user
    User.current = current_user
  end

  def set_searchable_records
    @records_search = RecordProperty.where.not(datum_type: ["Chemistry", "Spot"]).search(params[:q])
    @records_search.sorts = "updated_at ASC" if @records_search.sorts.empty?
    @records = @records_search.result.page(params[:page]).per(params[:per_page])
  end

end
