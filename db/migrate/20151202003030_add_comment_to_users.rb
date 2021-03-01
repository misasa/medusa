class AddCommentToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:users, "ユーザ")
    change_column_comment(:users, :id, "ID")
    change_column_comment(:users, :email, "Eメールアドレス")
    change_column_comment(:users, :encrypted_password, "暗号化パスワード")
    change_column_comment(:users, :reset_password_token, "パスワードリセット")
    change_column_comment(:users, :reset_password_sent_at, "リセットパスワード送信日時")
    change_column_comment(:users, :remember_created_at, "ログイン状態保持作成日時")
    change_column_comment(:users, :sign_in_count, "サインイン回数")
    change_column_comment(:users, :current_sign_in_at, "今回サインイン日時")
    change_column_comment(:users, :last_sign_in_at, "前回サインイン日時")
    change_column_comment(:users, :current_sign_in_ip, "今回サインインIPアドレス")
    change_column_comment(:users, :last_sign_in_ip, "前回サインインIPアドレス")
    change_column_comment(:users, :created_at, "作成日時")
    change_column_comment(:users, :updated_at, "更新日時")
    change_column_comment(:users, :administrator, "管理者フラグ")
    change_column_comment(:users, :family_name, "姓")
    change_column_comment(:users, :first_name, "名")
    change_column_comment(:users, :description, "説明")
    change_column_comment(:users, :username, "ユーザ名")
    change_column_comment(:users, :box_id, "保管場所ID")
  end
end
