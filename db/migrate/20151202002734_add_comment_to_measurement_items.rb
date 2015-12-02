class AddCommentToMeasurementItems < ActiveRecord::Migration
  def change
    change_table "measurement_items" do |t|
      t.comment "測定項目"
      t.change_comment :id, "ID"
      t.change_comment :nickname, "名称"
      t.change_comment :description, "説明"
      t.change_comment :display_in_html, "HTML表記"
      t.change_comment :display_in_tex, "TEX表記"
      t.change_comment :unit_id, "単位ID"
    end
  end
end
