class AddCommentToTables < ActiveRecord::Migration
  def change
    change_table "tables" do |t|
      t.comment "表"
      t.change_comment :id, "ID"
      t.change_comment :bib_id, "参考文献ID"
      t.change_comment :measurement_category_id, "測定種別ID"
      t.change_comment :description, "説明"
      t.change_comment :with_average, "平均値表示フラグ"
      t.change_comment :with_place, "場所表示フラグ"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
      t.change_comment :with_age, "年代表示フラグ"
      t.change_comment :age_unit, "年代単位"
    end
  end
end
