class AddScaleToMeasurementCategories < ActiveRecord::Migration
  def change
    add_column :measurement_categories, :scale, :integer
  end
end
