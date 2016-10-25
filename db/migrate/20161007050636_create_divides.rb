class CreateDivides < ActiveRecord::Migration
  def change
    create_table :divides do |t|
      t.comment "分取"
      t.integer :before_specimen_quantity_id, comment: "分取前試料量ID"
      t.boolean :divide_flg, default: false, null: false, comment: "分取フラグ"
      t.string :log, comment: "ログ"
      t.timestamps
    end
  end
end
