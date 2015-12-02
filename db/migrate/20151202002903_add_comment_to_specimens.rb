class AddCommentToSpecimens < ActiveRecord::Migration
  def change
    change_table "specimens" do |t|
      t.comment "標本"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :specimen_type, "標本種別"
      t.change_comment :description, "説明"
      t.change_comment :parent_id, "親標本ID"
      t.change_comment :place_id, "場所ID"
      t.change_comment :box_id, "保管場所ID"
      t.change_comment :physical_form_id, "形状ID"
      t.change_comment :classification_id, "分類ID"
      t.change_comment :quantity, "数量"
      t.change_comment :quantity_unit, "数量単位"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
      t.change_comment :igsn, "IGSN"
      t.change_comment :age_min, "年代（最小）"
      t.change_comment :age_max, "年代（最大）"
      t.change_comment :age_unit, "年代単位"
      t.change_comment :size, "サイズ"
      t.change_comment :size_unit, "サイズ単位"
      t.change_comment :collected_at, "採取日時"
      t.change_comment :collection_date_precision, "採取日時精度"
      t.change_comment :collector, "採取者"
      t.change_comment :collector_detail, "採取詳細情報"
    end
  end
end
