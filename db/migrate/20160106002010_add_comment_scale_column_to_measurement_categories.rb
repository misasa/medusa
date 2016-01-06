class AddCommentScaleColumnToMeasurementCategories < ActiveRecord::Migration
  def change
    change_table "measurement_categories" do |t|
      t.change_comment :scale, "有効精度"
    end
  end
end
