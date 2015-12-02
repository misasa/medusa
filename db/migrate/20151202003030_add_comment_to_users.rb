class AddCommentToUsers < ActiveRecord::Migration
  def change
    change_table "users" do |t|
      t.comment "ユーザ"
      t.change_comment :id, "ID"
      t.change_comment :email, "Eメールアドレス"
      t.change_comment :encrypted_password, "暗号化パスワード"
      t.change_comment :reset_password_token, "パスワードリセット"
      t.change_comment :reset_password_sent_at, "リセットパスワード送信日時"
      t.change_comment :remember_created_at, "ログイン状態保持作成日時"
      t.change_comment :sign_in_count, "サインイン回数"
      t.change_comment :current_sign_in_at, "今回サインイン日時"
      t.change_comment :last_sign_in_at, "前回サインイン日時"
      t.change_comment :current_sign_in_ip, "今回サインインIPアドレス"
      t.change_comment :last_sign_in_ip, "前回サインインIPアドレス"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
      t.change_comment :administrator, "管理者フラグ"
      t.change_comment :family_name, "姓"
      t.change_comment :first_name, "名"
      t.change_comment :description, "説明"
      t.change_comment :username, "ユーザ名"
      t.change_comment :box_id, "保管場所ID"
    end
  end
end
