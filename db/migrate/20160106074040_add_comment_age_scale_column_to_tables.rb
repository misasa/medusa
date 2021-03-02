class AddCommentAgeScaleColumnToTables < ActiveRecord::Migration[4.2]
  def change
    change_column_comment(:tables, :age_scale, "有効精度")
  end
end
