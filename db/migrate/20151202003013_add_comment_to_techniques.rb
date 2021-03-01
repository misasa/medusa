class AddCommentToTechniques < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:techniques, "分析手法")
    change_column_comment(:techniques, :id, "ID")
    change_column_comment(:techniques, :name, "名称")
    change_column_comment(:techniques, :created_at, "作成日時")
    change_column_comment(:techniques, :updated_at, "更新日時")
  end
end
