class AddCommentToGlobalQrs < ActiveRecord::Migration
  def change
    change_table "global_qrs" do |t|
      t.comment "QRコード"
      t.change_comment :id, "ID"
      t.change_comment :record_property_id, "レコードプロパティID"
      t.change_comment :file_name, "ファイル名"
      t.change_comment :content_type, "MIME Content-Type"
      t.change_comment :file_size, "ファイルサイズ"
      t.change_comment :file_updated_at, "ファイル更新日時"
      t.change_comment :identifier, "識別子"
    end
  end
end
