class AddCaptionToTables < ActiveRecord::Migration[4.2]
  def change
    change_table :tables do |t|
      t.rename :description, :caption
      t.text :description, comment: "説明"
    end
    change_column_comment(:tables, :caption, "表題")
  end
end
