class AddCommentToSpecimenCustomAttributes < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:specimen_custom_attributes, "標本別カスタム属性")
    change_column_comment(:specimen_custom_attributes, :id, "ID")
    change_column_comment(:specimen_custom_attributes, :specimen_id, "標本ID")
    change_column_comment(:specimen_custom_attributes, :custom_attribute_id, "カスタム属性ID")
    change_column_comment(:specimen_custom_attributes, :value, "値")
    change_column_comment(:specimen_custom_attributes, :created_at, "作成日時")
    change_column_comment(:specimen_custom_attributes, :updated_at, "更新日時")
  end
end
