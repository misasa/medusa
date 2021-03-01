class AddCommentToCategoryMeasurementItems < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:category_measurement_items, "測定種別別測定項目定義")
    change_column_comment(:category_measurement_items, :id, "ID")
    change_column_comment(:category_measurement_items, :measurement_item_id, "測定項目ID")
    change_column_comment(:category_measurement_items, :measurement_category_id, "測定種別ID")
    change_column_comment(:category_measurement_items, :position, "表示位置")
    change_column_comment(:category_measurement_items, :unit_id, "単位ID")
    change_column_comment(:category_measurement_items, :scale, "有効精度")
  end
end
