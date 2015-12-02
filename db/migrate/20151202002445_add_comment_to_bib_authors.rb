class AddCommentToBibAuthors < ActiveRecord::Migration
  def change
    change_table "bib_authors" do |t|
      t.comment "参考文献著者"
      t.change_comment :id, "ID"
      t.change_comment :bib_id, "参考文献ID"
      t.change_comment :author_id, "著者ID"
      t.change_comment :priority, "優先度"
    end
  end
end
