class AddCommentToGroups < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:groups, "グループ")
    change_column_comment(:groups, :id, "ID")
    change_column_comment(:groups, :name, "名称")
    change_column_comment(:groups, :created_at, "作成日時")
    change_column_comment(:groups, :updated_at, "更新日時")
  end
end
