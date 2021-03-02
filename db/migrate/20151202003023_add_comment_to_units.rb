class AddCommentToUnits < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:units, "単位")
    change_column_comment(:units, :id, "ID")
    change_column_comment(:units, :name, "名称")
    change_column_comment(:units, :created_at, "作成日時")
    change_column_comment(:units, :updated_at, "更新日時")
    change_column_comment(:units, :conversion, "変換")
    change_column_comment(:units, :html, "HTML表記")
    change_column_comment(:units, :text, "テキスト")
  end
end
