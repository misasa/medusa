class CreateMeasurementCategories < ActiveRecord::Migration
  def change
    create_table :measurement_categories do |t|
      t.string :name
      t.string :description
      t.text   :unit
    end
  end
end
