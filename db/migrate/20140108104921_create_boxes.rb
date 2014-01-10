class CreateBoxes < ActiveRecord::Migration
  def change
    create_table :boxes do |t|
      t.string  :name
      t.integer :parent_id
      t.integer :position
      t.string  :path
      t.integer :box_type_id
      
      t.timestamps
    end
    
    add_index :boxes, :parent_id
    add_index :boxes, :box_type_id
  end
end