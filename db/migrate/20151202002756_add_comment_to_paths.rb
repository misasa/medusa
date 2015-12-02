class AddCommentToPaths < ActiveRecord::Migration
  def change
    change_table "paths" do |t|
      t.comment "保管場所履歴"
      t.change_comment :id, "ID"
      t.change_comment :datum_id, "対象ID"
      t.change_comment :datum_type, "対象種別"
      t.change_comment :ids, "保管場所パス"
      t.change_comment :brought_in_at, "持込日時"
      t.change_comment :brought_out_at, "持出日時"
      t.change_comment :brought_in_by_id, "持込者ID"
      t.change_comment :brought_out_by_id, "持出者ID"
    end
  end
end
