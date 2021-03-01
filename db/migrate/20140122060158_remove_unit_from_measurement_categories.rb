class RemoveUnitFromMeasurementCategories < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :measurement_categories, :unit, :string
  end
  
  def self.down
    add_column :measurement_categories, :unit, :string
  end
end
