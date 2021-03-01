class CreateDivides < ActiveRecord::Migration[4.2]
  def change
    create_table :divides do |t|
      t.integer :before_specimen_quantity_id, comment: "分取前試料量ID"
      t.boolean :divide_flg, default: false, null: false, comment: "分取フラグ"
      t.string :log, comment: "ログ"
      t.timestamps
    end
    change_table_comment(:divides, "分取")

    add_index :divides, :before_specimen_quantity_id
  end
end
