class CreateAnalysisElements < ActiveRecord::Migration
  def change
    create_table :analysis_elements do |t|
      t.integer :analysis_id, :null => false
      t.integer :measurement_item_id
      t.string  :info
      t.float   :data
      t.string  :label
      t.string  :unit
      t.text    :description
      t.float   :error
      
      t.timestamps
    end
    
    add_index :analysis_elements, :analysis_id
    add_index :analysis_elements, :measurement_item_id
  end
end
