class AddUnitAndScaleToCategoryMeasurementItems < ActiveRecord::Migration
  def change
    add_column :category_measurement_items, :unit_id, :integer
    add_column :category_measurement_items, :scale, :integer
  end
end
