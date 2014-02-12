class AddUnitIdToMeasurementItems < ActiveRecord::Migration
  def change
    add_column :measurement_items, :unit_id, :integer 
  end
end
