class AddCommentToTechniques < ActiveRecord::Migration
  def change
    change_table "techniques" do |t|
      t.comment "分析手法"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
