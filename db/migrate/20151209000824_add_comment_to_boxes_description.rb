class AddCommentToBoxesDescription < ActiveRecord::Migration
  def change
    change_table "boxes" do |t|
      t.change_comment :description, "説明"
    end
  end
end
