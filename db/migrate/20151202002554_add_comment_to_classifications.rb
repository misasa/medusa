class AddCommentToClassifications < ActiveRecord::Migration
  def change
    change_table "classifications" do |t|
      t.comment "分類"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :full_name, "正式名称"
      t.change_comment :description, "説明"
      t.change_comment :parent_id, "親分類ID"
      t.change_comment :lft, "lft"
      t.change_comment :rgt, "rgt"
      t.change_comment :sesar_material, "SESAR:material"
      t.change_comment :sesar_classification, "SESAR:classification"
    end
  end
end
