class AddCommentToAttachmentFiles < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:attachment_files, "添付ファイル")
    change_column_comment(:attachment_files, :id, "ID")
    change_column_comment(:attachment_files, :name, "名称")
    change_column_comment(:attachment_files, :description, "説明")
    change_column_comment(:attachment_files, :md5hash, "MD5")
    change_column_comment(:attachment_files, :data_file_name, "ファイル名")
    change_column_comment(:attachment_files, :data_content_type, "MIME Content-Type")
    change_column_comment(:attachment_files, :data_file_size, "ファイルサイズ")
    change_column_comment(:attachment_files, :data_updated_at, "ファイル更新日時")
    change_column_comment(:attachment_files, :original_geometry, "画素数")
    change_column_comment(:attachment_files, :affine_matrix, "アフィン変換行列")
    change_column_comment(:attachment_files, :created_at, "作成日時")
    change_column_comment(:attachment_files, :updated_at, "更新日時")
  end
end
