class AddScaleToMeasurementCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :measurement_categories, :scale, :integer
  end
end
