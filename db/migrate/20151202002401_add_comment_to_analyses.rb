class AddCommentToAnalyses < ActiveRecord::Migration
  def change
    change_table "analyses" do |t|
      t.comment "分析"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :description, "説明"
      t.change_comment :specimen_id, "標本ID"
      t.change_comment :operator, "オペレータ"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
      t.change_comment :technique_id, "分析手法ID"
      t.change_comment :device_id, "分析機器ID"
    end
  end
end
