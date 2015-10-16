class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  # googleコールバックを処理する
  # カレントユーザ設定済み（＝ログイン後）：自ユーザに紐づく googleアカウント情報を作成する
  # カレントユーザ未設定（＝ログイン前）：omniauth 認証情報にマッチするユーザにてログインする
  def google_oauth2
    access_token = request.env["omniauth.auth"]
    if current_user
      Omniauth.find_or_create_by(user_id: current_user.id, provider: access_token.provider, uid: access_token.uid)
      redirect_to edit_account_path
    else
      user = Omniauth.find_user_by_auth(access_token)
      if user
        sign_in_and_redirect(user, event: :authentication)
      else
        redirect_to new_user_session_path
      end
    end
  end
end
