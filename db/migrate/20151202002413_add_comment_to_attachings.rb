class AddCommentToAttachings < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:attachings, "添付")
    change_column_comment(:attachings, :id, "ID")
    change_column_comment(:attachings, :attachment_file_id, "添付ファイルID")
    change_column_comment(:attachings, :attachable_id, "添付先ID")
    change_column_comment(:attachings, :attachable_type, "添付先タイプ")
    change_column_comment(:attachings, :position, "表示位置")
    change_column_comment(:attachings, :created_at, "作成日時")
    change_column_comment(:attachings, :updated_at, "更新日時")
  end
end
