class AddUnitAndScaleToCategoryMeasurementItems < ActiveRecord::Migration[4.2]
  def change
    add_column :category_measurement_items, :unit_id, :integer
    add_column :category_measurement_items, :scale, :integer
  end
end
