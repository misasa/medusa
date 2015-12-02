class AddCommentToAuthors < ActiveRecord::Migration
  def change
    change_table "authors" do |t|
      t.comment "著者"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
