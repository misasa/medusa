class AddCommentToRecordProperties < ActiveRecord::Migration
  def change
    change_table "record_properties" do |t|
      t.comment "レコードプロパティ"
      t.change_comment :id, "ID"
      t.change_comment :datum_id, "レコードID"
      t.change_comment :datum_type, "レコード種別"
      t.change_comment :user_id, "ユーザID"
      t.change_comment :group_id, "グループID"
      t.change_comment :global_id, "グローバルID"
      t.change_comment :published, "公開済フラグ"
      t.change_comment :published_at, "公開日時"
      t.change_comment :owner_readable, "読取許可（所有者）"
      t.change_comment :owner_writable, "書込許可（所有者）"
      t.change_comment :group_readable, "読取許可（グループ）"
      t.change_comment :group_writable, "書込許可（グループ）"
      t.change_comment :guest_readable, "読取許可（その他）"
      t.change_comment :guest_writable, "書込許可（その他）"
      t.change_comment :name, "名称"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
