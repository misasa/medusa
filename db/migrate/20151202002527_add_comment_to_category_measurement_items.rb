class AddCommentToCategoryMeasurementItems < ActiveRecord::Migration
  def change
    change_table "category_measurement_items" do |t|
      t.comment "測定種別別測定項目定義"
      t.change_comment :id, "ID"
      t.change_comment :measurement_item_id, "測定項目ID"
      t.change_comment :measurement_category_id, "測定種別ID"
      t.change_comment :position, "表示位置"
      t.change_comment :unit_id, "単位ID"
      t.change_comment :scale, "有効精度"
    end
  end
end
