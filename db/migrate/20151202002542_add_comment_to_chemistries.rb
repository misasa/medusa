class AddCommentToChemistries < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:chemistries, "分析要素")
    change_column_comment(:chemistries, :id, "ID")
    change_column_comment(:chemistries, :analysis_id, "分析ID")
    change_column_comment(:chemistries, :measurement_item_id, "測定項目ID")
    change_column_comment(:chemistries, :info, "情報")
    change_column_comment(:chemistries, :value, "測定値")
    change_column_comment(:chemistries, :label, "ラベル")
    change_column_comment(:chemistries, :description, "説明")
    change_column_comment(:chemistries, :uncertainty, "不確実性")
    change_column_comment(:chemistries, :created_at, "作成日時")
    change_column_comment(:chemistries, :updated_at, "更新日時")
    change_column_comment(:chemistries, :unit_id, "単位ID")
  end
end
