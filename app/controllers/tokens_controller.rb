class TokensController < ActionController::Base
  def create
    if params[:staff_id].present? && params[:card_id].present?
      user = User.find_by(staff_id: params[:staff_id], card_id: params[:card_id])
      token = user && user.access_token
      render json: { token: token }, status: :created and return if token.present?
    end
    render json: { message: "cannot assign access token." }, status: :unauthorized
  end
end
