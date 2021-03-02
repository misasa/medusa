class AddCommentToAuthors < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:authors, "著者")
    change_column_comment(:authors, :id, "ID")
    change_column_comment(:authors, :name, "名称")
    change_column_comment(:authors, :created_at, "作成日時")
    change_column_comment(:authors, :updated_at, "更新日時")
  end
end
