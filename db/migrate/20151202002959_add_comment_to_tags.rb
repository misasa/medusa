class AddCommentToTags < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:tags, "タグ")
    change_column_comment(:tags, :id, "ID")
    change_column_comment(:tags, :name, "名称")
  end
end
