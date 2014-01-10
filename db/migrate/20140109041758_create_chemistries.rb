class CreateChemistries < ActiveRecord::Migration
  def change
    create_table :chemistries do |t|
      t.integer :analysis_id, :null => false
      t.integer :measurement_item_id
      t.string  :info
      t.float   :value
      t.string  :label
      t.string  :unit
      t.text    :description
      t.float   :uncertainty
      
      t.timestamps
    end
    
    add_index :chemistries, :analysis_id
    add_index :chemistries, :measurement_item_id
  end
end
