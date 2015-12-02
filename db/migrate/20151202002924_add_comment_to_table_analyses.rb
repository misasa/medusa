class AddCommentToTableAnalyses < ActiveRecord::Migration
  def change
    change_table "table_analyses" do |t|
      t.comment "表内分析情報"
      t.change_comment :id, "ID"
      t.change_comment :table_id, "表ID"
      t.change_comment :specimen_id, "標本ID"
      t.change_comment :analysis_id, "分析ID"
      t.change_comment :priority, "優先度"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
