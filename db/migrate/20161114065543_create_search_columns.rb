class CreateSearchColumns < ActiveRecord::Migration
  def up
    create_table :search_columns do |t|
      t.integer :user_id, null: false, comment: "ユーザID"
      t.string :datum_type, comment: "モデル種別"
      t.string :name, comment: "カラム名"
      t.string :display_name, comment: "表示名"
      t.integer :display_order, comment: "表示順"
      t.integer :display_type, comment: "表示種別"
      t.timestamps
    end
    add_index :search_columns, :user_id
  end

  def down
    drop_table :search_columns
  end
end
