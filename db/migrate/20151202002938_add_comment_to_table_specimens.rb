class AddCommentToTableSpecimens < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:table_specimens, "表内標本情報")
    change_column_comment(:table_specimens, :id, "ID")
    change_column_comment(:table_specimens, :table_id, "表ID")
    change_column_comment(:table_specimens, :specimen_id, "標本ID")
    change_column_comment(:table_specimens, :position, "表示位置")
    change_column_comment(:table_specimens, :created_at, "作成日時")
    change_column_comment(:table_specimens, :updated_at, "更新日時")
  end
end
