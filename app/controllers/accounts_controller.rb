class AccountsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource,except: [ :find_by_global_id ]

  def find_by_global_id
    redirect_to "/records/#{params[:global_id]}"
  end

  def show
    respond_with @user
  end

  def edit
    respond_with @user
  end

  def update
    pa = user_params
    pa.delete(:password) if pa[:password].blank?
    pa.delete(:password_confirmation) if pa[:password_confirmation].blank?
    @user.update_attributes(pa)
    respond_with(@user,location: account_path)
  end

  def unlink
    @user.omniauths.find_by(provider: params[:provider]).destroy
    respond_with(@user,location: edit_account_path)
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :family_name,
      :first_name,
      :description,
      :box_id,
      :username
    )
  end

  def find_resource
    @user = User.find(User.current.id)
  end

end
