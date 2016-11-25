class TokensController < ActionController::Base
  def create
    if params[:api_key].present?
      user = User.find_by(api_key: params[:api_key])
      token = user && user.access_token
      render json: { token: token }, status: :created and return if token.present?
    end
    render json: { message: "cannot assign access token." }, status: :unauthorized
  end
end
