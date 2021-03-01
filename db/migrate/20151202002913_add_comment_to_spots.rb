class AddCommentToSpots < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:spots, "分析点")
    change_column_comment(:spots, :id, "ID")
    change_column_comment(:spots, :attachment_file_id, "添付ファイルID")
    change_column_comment(:spots, :name, "名称")
    change_column_comment(:spots, :description, "説明")
    change_column_comment(:spots, :spot_x, "X座標")
    change_column_comment(:spots, :spot_y, "Y座標")
    change_column_comment(:spots, :target_uid, "対象UID")
    change_column_comment(:spots, :radius_in_percent, "半径（％）")
    change_column_comment(:spots, :stroke_color, "線色")
    change_column_comment(:spots, :stroke_width, "線幅")
    change_column_comment(:spots, :fill_color, "塗り潰し色")
    change_column_comment(:spots, :opacity, "透明度")
    change_column_comment(:spots, :with_cross, "クロス表示フラグ")
    change_column_comment(:spots, :created_at, "作成日時")
    change_column_comment(:spots, :updated_at, "更新日時")
  end
end
