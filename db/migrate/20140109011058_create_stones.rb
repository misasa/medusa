class CreateStones < ActiveRecord::Migration[4.2]
  def change
    create_table :stones do |t|
      t.string  :name
      t.string  :stone_type
      t.text    :description
      t.integer :parent_id
      t.integer :place_id
      t.integer :box_id
      t.integer :physical_form_id
      t.integer :classification_id
      t.float   :quantity
      t.string  :quantity_unit
      
      t.timestamps
    end
    
    add_index :stones, :parent_id
    add_index :stones, :physical_form_id
    add_index :stones, :classification_id
  end
end
