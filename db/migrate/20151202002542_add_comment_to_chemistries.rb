class AddCommentToChemistries < ActiveRecord::Migration
  def change
    change_table "chemistries" do |t|
      t.comment "分析要素"
      t.change_comment :id, "ID"
      t.change_comment :analysis_id, "分析ID"
      t.change_comment :measurement_item_id, "測定項目ID"
      t.change_comment :info, "情報"
      t.change_comment :value, "測定値"
      t.change_comment :label, "ラベル"
      t.change_comment :description, "説明"
      t.change_comment :uncertainty, "不確実性"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
      t.change_comment :unit_id, "単位ID"
    end
  end
end
