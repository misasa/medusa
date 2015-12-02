class AddCommentToBoxes < ActiveRecord::Migration
  def change
    change_table "boxes" do |t|
      t.comment "保管場所"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :parent_id, "親保管場所ID"
      t.change_comment :position, "表示位置"
      t.change_comment :path, "保管場所パス"
      t.change_comment :box_type_id, "保管場所種別ID"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
