class AddCommentToBoxesDescription < ActiveRecord::Migration[4.2]
  def change
    change_column_comment(:boxes, :description, "説明")
  end
end
