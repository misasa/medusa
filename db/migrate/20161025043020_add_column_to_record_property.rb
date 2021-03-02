class AddColumnToRecordProperty < ActiveRecord::Migration[4.2]
  def change
    change_table :record_properties do |t|
      t.boolean :disposed, default: false, null: false, comment: "廃棄フラグ"
      t.datetime :disposed_at, comment: "廃棄日時"
      t.boolean :lost, default: false, null: false, comment: "紛失フラグ"
      t.datetime :lost_at, comment: "紛失日時"
    end
  end
end
