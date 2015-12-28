class AddCaptionToTables < ActiveRecord::Migration
  def change
    change_table :tables do |t|
      t.rename :description, :caption
      t.text :description, comment: "説明"
      t.change_comment :caption, "表題"
    end
  end
end
