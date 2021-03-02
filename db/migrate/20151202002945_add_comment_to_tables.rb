class AddCommentToTables < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:tables, "表")
    change_column_comment(:tables, :id, "ID")
    change_column_comment(:tables, :bib_id, "参考文献ID")
    change_column_comment(:tables, :measurement_category_id, "測定種別ID")
    change_column_comment(:tables, :description, "説明")
    change_column_comment(:tables, :with_average, "平均値表示フラグ")
    change_column_comment(:tables, :with_place, "場所表示フラグ")
    change_column_comment(:tables, :created_at, "作成日時")
    change_column_comment(:tables, :updated_at, "更新日時")
    change_column_comment(:tables, :with_age, "年代表示フラグ")
    change_column_comment(:tables, :age_unit, "年代単位")
  end
end
