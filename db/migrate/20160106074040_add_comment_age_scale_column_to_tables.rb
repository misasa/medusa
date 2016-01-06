class AddCommentAgeScaleColumnToTables < ActiveRecord::Migration
  def change
    change_table "tables" do |t|
      t.change_comment :age_scale, "有効精度"
    end
  end
end
