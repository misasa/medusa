class AddCommentToAttachmentFiles < ActiveRecord::Migration
  def change
    change_table "attachment_files" do |t|
      t.comment "添付ファイル"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :description, "説明"
      t.change_comment :md5hash, "MD5"
      t.change_comment :data_file_name, "ファイル名"
      t.change_comment :data_content_type, "MIME Content-Type"
      t.change_comment :data_file_size, "ファイルサイズ"
      t.change_comment :data_updated_at, "ファイル更新日時"
      t.change_comment :original_geometry, "画素数"
      t.change_comment :affine_matrix, "アフィン変換行列"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
