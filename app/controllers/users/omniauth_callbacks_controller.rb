class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  # googleコールバックを処理する
  def google_oauth2
    oauth(request.env["omniauth.auth"])
  end

  def shibboleth
    oauth(request.env["omniauth.auth"])
  end

  private

  # カレントユーザ設定済み（＝ログイン後）：自ユーザに紐づく omniauth情報を作成する
  # カレントユーザ未設定（＝ログイン前）：omniauth 認証情報にマッチするユーザにてログインする
  def oauth(auth_hash)
    if current_user
      Omniauth.find_or_create_by(user_id: current_user.id, provider: auth_hash.provider, uid: auth_hash.uid)
      redirect_to edit_account_path
    else
      user = Omniauth.find_user_by_auth(auth_hash)
      if user
        sign_in_and_redirect(user, event: :authentication)
      else
        redirect_to new_user_session_path
      end
    end
  end
end
