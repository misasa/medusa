class AddScaleToMeasurementItems < ActiveRecord::Migration
  def change
    add_column :measurement_items, :scale, :integer
  end
end
