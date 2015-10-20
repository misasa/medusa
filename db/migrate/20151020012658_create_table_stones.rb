class CreateTableStones < ActiveRecord::Migration
  def change
    create_table :table_stones do |t|
      t.integer :table_id
      t.integer :stone_id
      t.integer :position

      t.timestamps
    end

    add_index :table_stones, :table_id
    add_index :table_stones, :stone_id
  end
end
