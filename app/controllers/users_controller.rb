class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = User.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
#    @users = @search.result.page(params[:page]).per(params[:per_page])
    @users = @search.result
    respond_with @users
  end

  def show
    respond_with @user
  end

  def new
    @user = User.new
    respond_with @user
  end

  def edit
    respond_with @user
  end

  def create
    @user = User.new(user_params)
    @user.save
    respond_with(@user, location: users_path)
  end

  def update
    pa = user_params
    pa.delete(:password) if pa[:password].blank?
    pa.delete(:password_confirmation) if pa[:password_confirmation].blank?
    @user.update_attributes(pa)
    respond_with(@user, location: users_path)
  end
  
  def destroy
    @user.destroy
    respond_with @user
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :administrator,
      :family_name,
      :first_name,
      :description,
      :box_id,
      :username,
      group_ids: []
    )
  end

  def find_resource
    @user = User.find(params[:id])
  end

end
