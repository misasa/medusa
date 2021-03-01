class AddCommentToClassifications < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:classifications, "分類")
    change_column_comment(:classifications, :id, "ID")
    change_column_comment(:classifications, :name, "名称")
    change_column_comment(:classifications, :full_name, "正式名称")
    change_column_comment(:classifications, :description, "説明")
    change_column_comment(:classifications, :parent_id, "親分類ID")
    change_column_comment(:classifications, :lft, "lft")
    change_column_comment(:classifications, :rgt, "rgt")
    change_column_comment(:classifications, :sesar_material, "SESAR:material")
    change_column_comment(:classifications, :sesar_classification, "SESAR:classification")
  end
end
