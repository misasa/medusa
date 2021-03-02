class AddCommentToRecordProperties < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:record_properties, "レコードプロパティ")
    change_column_comment(:record_properties, :id, "ID")
    change_column_comment(:record_properties, :datum_id, "レコードID")
    change_column_comment(:record_properties, :datum_type, "レコード種別")
    change_column_comment(:record_properties, :user_id, "ユーザID")
    change_column_comment(:record_properties, :group_id, "グループID")
    change_column_comment(:record_properties, :global_id, "グローバルID")
    change_column_comment(:record_properties, :published, "公開済フラグ")
    change_column_comment(:record_properties, :published_at, "公開日時")
    change_column_comment(:record_properties, :owner_readable, "読取許可（所有者）")
    change_column_comment(:record_properties, :owner_writable, "書込許可（所有者）")
    change_column_comment(:record_properties, :group_readable, "読取許可（グループ）")
    change_column_comment(:record_properties, :group_writable, "書込許可（グループ）")
    change_column_comment(:record_properties, :guest_readable, "読取許可（その他）")
    change_column_comment(:record_properties, :guest_writable, "書込許可（その他）")
    change_column_comment(:record_properties, :name, "名称")
    change_column_comment(:record_properties, :created_at, "作成日時")
    change_column_comment(:record_properties, :updated_at, "更新日時")
  end
end
