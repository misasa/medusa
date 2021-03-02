class AddUnitIdToMeasurementItems < ActiveRecord::Migration[4.2]
  def change
    add_column :measurement_items, :unit_id, :integer 
  end
end
