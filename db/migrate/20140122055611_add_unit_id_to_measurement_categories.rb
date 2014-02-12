class AddUnitIdToMeasurementCategories < ActiveRecord::Migration
  def change
    add_column :measurement_categories, :unit_id, :integer
  end
end
