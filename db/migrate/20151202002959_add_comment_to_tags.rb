class AddCommentToTags < ActiveRecord::Migration
  def change
    change_table "tags" do |t|
      t.comment "タグ"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
    end
  end
end
