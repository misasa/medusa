class AddCommentToTableAnalyses < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:table_analyses, "表内分析情報")
    change_column_comment(:table_analyses, :id, "ID")
    change_column_comment(:table_analyses, :table_id, "表ID")
    change_column_comment(:table_analyses, :specimen_id, "標本ID")
    change_column_comment(:table_analyses, :analysis_id, "分析ID")
    change_column_comment(:table_analyses, :priority, "優先度")
    change_column_comment(:table_analyses, :created_at, "作成日時")
    change_column_comment(:table_analyses, :updated_at, "更新日時")
  end
end
