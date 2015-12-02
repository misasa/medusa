class AddCommentToAttachings < ActiveRecord::Migration
  def change
    change_table "attachings" do |t|
      t.comment "添付"
      t.change_comment :id, "ID"
      t.change_comment :attachment_file_id, "添付ファイルID"
      t.change_comment :attachable_id, "添付先ID"
      t.change_comment :attachable_type, "添付先タイプ"
      t.change_comment :position, "表示位置"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
