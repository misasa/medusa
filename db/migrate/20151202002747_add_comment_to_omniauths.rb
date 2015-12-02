class AddCommentToOmniauths < ActiveRecord::Migration
  def change
    change_table "omniauths" do |t|
      t.comment "シングルサインオン情報"
      t.change_comment :id, "ID"
      t.change_comment :user_id, "ユーザID"
      t.change_comment :provider, "プロバイダ"
      t.change_comment :uid, "UID"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
