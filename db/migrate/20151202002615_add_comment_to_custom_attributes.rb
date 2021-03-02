class AddCommentToCustomAttributes < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:custom_attributes, "カスタム属性")
    change_column_comment(:custom_attributes, :id, "ID")
    change_column_comment(:custom_attributes, :name, "名称")
    change_column_comment(:custom_attributes, :sesar_name, "SESAR属性名称")
    change_column_comment(:custom_attributes, :created_at, "作成日時")
    change_column_comment(:custom_attributes, :updated_at, "更新日時")
  end
end
