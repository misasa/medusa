class AddCommentToBoxTypes < ActiveRecord::Migration
  def change
    change_table "box_types" do |t|
      t.comment "保管場所種別"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :description, "説明"
    end
  end
end
