class AddCommentToDevices < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:devices, "分析機器")
    change_column_comment(:devices, :id, "ID")
    change_column_comment(:devices, :name, "名称")
    change_column_comment(:devices, :created_at, "作成日時")
    change_column_comment(:devices, :updated_at, "更新日時")
  end
end
