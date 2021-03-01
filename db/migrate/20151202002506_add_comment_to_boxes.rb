class AddCommentToBoxes < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:boxes, "保管場所")
    change_column_comment(:boxes, :id, "ID")
    change_column_comment(:boxes, :name, "名称")
    change_column_comment(:boxes, :parent_id, "親保管場所ID")
    change_column_comment(:boxes, :position, "表示位置")
    change_column_comment(:boxes, :path, "保管場所パス")
    change_column_comment(:boxes, :box_type_id, "保管場所種別ID")
    change_column_comment(:boxes, :created_at, "作成日時")
    change_column_comment(:boxes, :updated_at, "更新日時")
  end
end
