class AddCommentToMeasurementCategories < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:measurement_categories, "測定種別")
    change_column_comment(:measurement_categories, :id, "ID")
    change_column_comment(:measurement_categories, :name, "名称")
    change_column_comment(:measurement_categories, :description, "説明")
    change_column_comment(:measurement_categories, :unit_id, "単位ID")
  end
end
