class AddIsTemplateToMeasurementCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :measurement_categories, :is_template, :boolean, default: false, null: false
  end
end
