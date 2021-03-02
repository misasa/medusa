class AddCommentToPaths < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:paths, "保管場所履歴")
    change_column_comment(:paths, :id, "ID")
    change_column_comment(:paths, :datum_id, "対象ID")
    change_column_comment(:paths, :datum_type, "対象種別")
    change_column_comment(:paths, :ids, "保管場所パス")
    change_column_comment(:paths, :brought_in_at, "持込日時")
    change_column_comment(:paths, :brought_out_at, "持出日時")
    change_column_comment(:paths, :brought_in_by_id, "持込者ID")
    change_column_comment(:paths, :brought_out_by_id, "持出者ID")
  end
end
