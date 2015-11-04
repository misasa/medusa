class CreateTableAnalyses < ActiveRecord::Migration
  def change
    create_table :table_analyses do |t|
      t.integer :table_id
      t.integer :stone_id
      t.integer :analysis_id
      t.integer :priority

      t.timestamps
    end

    add_index :table_analyses, :table_id
    add_index :table_analyses, :stone_id
    add_index :table_analyses, :analysis_id
  end
end
