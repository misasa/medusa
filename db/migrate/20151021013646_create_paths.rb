class CreatePaths < ActiveRecord::Migration
  def change
    create_table :paths do |t|
      t.integer :datum_id
      t.string  :datum_type
      t.integer :ids, array: true

      t.timestamp :brought_in_at
      t.timestamp :brought_out_at
    end
    add_index :paths, [:datum_id, :datum_type]
    add_index :paths, :ids, using: "gin"
  end
end
