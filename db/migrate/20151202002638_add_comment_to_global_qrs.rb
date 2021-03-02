class AddCommentToGlobalQrs < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:global_qrs, "QRコード")
    change_column_comment(:global_qrs, :id, "ID")
    change_column_comment(:global_qrs, :record_property_id, "レコードプロパティID")
    change_column_comment(:global_qrs, :file_name, "ファイル名")
    change_column_comment(:global_qrs, :content_type, "MIME Content-Type")
    change_column_comment(:global_qrs, :file_size, "ファイルサイズ")
    change_column_comment(:global_qrs, :file_updated_at, "ファイル更新日時")
    change_column_comment(:global_qrs, :identifier, "識別子")
  end
end
