class AddCommentToReferrings < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:referrings, "参照")
    change_column_comment(:referrings, :id, "ID")
    change_column_comment(:referrings, :bib_id, "参考文献ID")
    change_column_comment(:referrings, :referable_id, "参照元ID")
    change_column_comment(:referrings, :referable_type, "参照元種別")
    change_column_comment(:referrings, :created_at, "作成日時")
    change_column_comment(:referrings, :updated_at, "更新日時")
  end
end
