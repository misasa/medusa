class CreateStones < ActiveRecord::Migration
  def change
    create_table :stones do |t|
      t.string  :name
      t.string  :label_note
      t.string  :stone_type
      t.string  :box_old_id
      t.text    :description
      t.integer :parent_id
      t.integer :mount_id
      t.integer :place_id
      t.integer :box_id
      t.integer :physical_form_id
      t.integer :classification_id
      t.float   :weight_in_gram
      
      t.timestamps
    end
    
    add_index :stones, :parent_id
    add_index :stones, :physical_form_id
    add_index :stones, :classification_id
  end
end
