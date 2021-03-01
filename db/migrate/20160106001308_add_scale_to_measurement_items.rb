class AddScaleToMeasurementItems < ActiveRecord::Migration[4.2]
  def change
    add_column :measurement_items, :scale, :integer
  end
end
