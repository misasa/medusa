class AddCommentToTableSpecimens < ActiveRecord::Migration
  def change
    change_table "table_specimens" do |t|
      t.comment "表内標本情報"
      t.change_comment :id, "ID"
      t.change_comment :table_id, "表ID"
      t.change_comment :specimen_id, "標本ID"
      t.change_comment :position, "表示位置"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
