class AddUnitIdToMeasurementCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :measurement_categories, :unit_id, :integer
  end
end
