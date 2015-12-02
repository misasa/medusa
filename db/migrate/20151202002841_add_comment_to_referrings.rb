class AddCommentToReferrings < ActiveRecord::Migration
  def change
    change_table "referrings" do |t|
      t.comment "参照"
      t.change_comment :id, "ID"
      t.change_comment :bib_id, "参考文献ID"
      t.change_comment :referable_id, "参照元ID"
      t.change_comment :referable_type, "参照元種別"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
