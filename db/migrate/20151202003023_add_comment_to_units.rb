class AddCommentToUnits < ActiveRecord::Migration
  def change
    change_table "units" do |t|
      t.comment "単位"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
      t.change_comment :conversion, "変換"
      t.change_comment :html, "HTML表記"
      t.change_comment :text, "テキスト"
    end
  end
end
