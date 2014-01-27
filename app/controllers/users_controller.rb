class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @users = User.all
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
    respond_with @user
  end

  def update
    @user.update_attributes(user_params)
    respond_with @user
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
      :box_id
    )
  end

  def find_resource
    @user = User.find(params[:id])
  end

end
