class AddCommentToAnalyses < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:analyses, "分析")
    change_column_comment(:analyses, :id, "ID")
    change_column_comment(:analyses, :name, "名称")
    change_column_comment(:analyses, :description, "説明")
    change_column_comment(:analyses, :specimen_id, "標本ID")
    change_column_comment(:analyses, :operator, "オペレータ")
    change_column_comment(:analyses, :created_at, "作成日時")
    change_column_comment(:analyses, :updated_at, "更新日時")
    change_column_comment(:analyses, :technique_id, "分析手法ID")
    change_column_comment(:analyses, :device_id, "分析機器ID")
  end
end
