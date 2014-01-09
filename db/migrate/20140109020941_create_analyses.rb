class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.string  :name
      t.text    :description
      t.integer :stone_id
      t.string  :technique
      t.string  :instrument
      t.string  :analyst
      
      t.timestamps
    end
    
    add_index :analyses, :stone_id
  end
end
