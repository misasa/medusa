class CreateStoneCustomAttributes < ActiveRecord::Migration
  def change
    create_table :stone_custom_attributes do |t|
      t.integer :stone_id
      t.integer :custom_attribute_id
      t.string :value
      t.timestamps
    end
    
    add_index :stone_custom_attributes, :stone_id
    add_index :stone_custom_attributes, :custom_attribute_id
  end
end
