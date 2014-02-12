class RemoveUnitFromMeasurementCategories < ActiveRecord::Migration
  def self.up
    remove_column :measurement_categories, :unit, :string
  end
  
  def self.down
    add_column :measurement_categories, :unit, :string
  end
end
