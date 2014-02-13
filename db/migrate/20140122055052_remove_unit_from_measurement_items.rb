class RemoveUnitFromMeasurementItems < ActiveRecord::Migration
  def self.up
    remove_column :measurement_items, :unit, :string
  end
  
  def self.down
    add_column :measurement_items, :unit, :string
  end
end
