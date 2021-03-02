class AddCommentToOmniauths < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:omniauths, "シングルサインオン情報")
    change_column_comment(:omniauths, :id, "ID")
    change_column_comment(:omniauths, :user_id, "ユーザID")
    change_column_comment(:omniauths, :provider, "プロバイダ")
    change_column_comment(:omniauths, :uid, "UID")
    change_column_comment(:omniauths, :created_at, "作成日時")
    change_column_comment(:omniauths, :updated_at, "更新日時")
  end
end
