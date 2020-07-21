class AddIsTemplateToMeasurementCategories < ActiveRecord::Migration
  def change
    add_column :measurement_categories, :is_template, :boolean, default: false, null: false
  end
end
