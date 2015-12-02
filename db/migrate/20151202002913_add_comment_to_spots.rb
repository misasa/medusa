class AddCommentToSpots < ActiveRecord::Migration
  def change
    change_table "spots" do |t|
      t.comment "分析点"
      t.change_comment :id, "ID"
      t.change_comment :attachment_file_id, "添付ファイルID"
      t.change_comment :name, "名称"
      t.change_comment :description, "説明"
      t.change_comment :spot_x, "X座標"
      t.change_comment :spot_y, "Y座標"
      t.change_comment :target_uid, "対象UID"
      t.change_comment :radius_in_percent, "半径（％）"
      t.change_comment :stroke_color, "線色"
      t.change_comment :stroke_width, "線幅"
      t.change_comment :fill_color, "塗り潰し色"
      t.change_comment :opacity, "透明度"
      t.change_comment :with_cross, "クロス表示フラグ"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
