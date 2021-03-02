class AddCommentToPhysicalForms < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:physical_forms, "形状")
    change_column_comment(:physical_forms, :id, "ID")
    change_column_comment(:physical_forms, :name, "名称")
    change_column_comment(:physical_forms, :description, "説明")
    change_column_comment(:physical_forms, :sesar_sample_type, "SESAR:sample_type")
  end
end
