class AddCommentToBoxTypes < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:box_types, "保管場所種別")
    change_column_comment(:box_types, :id, "ID")
    change_column_comment(:box_types, :name, "名称")
    change_column_comment(:box_types, :description, "説明")
  end
end
