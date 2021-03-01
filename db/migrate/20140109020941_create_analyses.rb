class CreateAnalyses < ActiveRecord::Migration[4.2]
  def change
    create_table :analyses do |t|
      t.string  :name
      t.text    :description
      t.integer :stone_id
      t.string  :technique
      t.string  :device
      t.string  :operator
      
      t.timestamps
    end
    
    add_index :analyses, :stone_id
  end
end
