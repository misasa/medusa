class AddCommentToMeasurementCategories < ActiveRecord::Migration
  def change
    change_table "measurement_categories" do |t|
      t.comment "測定種別"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :description, "説明"
      t.change_comment :unit_id, "単位ID"
    end
  end
end
