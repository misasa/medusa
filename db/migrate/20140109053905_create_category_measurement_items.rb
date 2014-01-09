class CreateCategoryMeasurementItems < ActiveRecord::Migration
  def change
    create_table :category_measurement_items do |t|
      t.integer :measurement_item_id
      t.integer :measurement_category_id
      t.integer :position
    end
    
    add_index :category_measurement_items, :measurement_item_id
    add_index :category_measurement_items, :measurement_category_id
  end
end
