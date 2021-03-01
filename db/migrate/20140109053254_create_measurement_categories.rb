class CreateMeasurementCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :measurement_categories do |t|
      t.string :name
      t.string :description
      t.text   :unit
    end
  end
end
