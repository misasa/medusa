class AddCommentToMeasurementItems < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:measurement_items, "測定項目")
    change_column_comment(:measurement_items, :id, "ID")
    change_column_comment(:measurement_items, :nickname, "名称")
    change_column_comment(:measurement_items, :description, "説明")
    change_column_comment(:measurement_items, :display_in_html, "HTML表記")
    change_column_comment(:measurement_items, :display_in_tex, "TEX表記")
    change_column_comment(:measurement_items, :unit_id, "単位ID")
  end
end
