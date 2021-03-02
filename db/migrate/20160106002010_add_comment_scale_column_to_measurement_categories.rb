class AddCommentScaleColumnToMeasurementCategories < ActiveRecord::Migration[4.2]
  def change
    change_column_comment(:measurement_categories, :scale, "有効精度")
  end
end
