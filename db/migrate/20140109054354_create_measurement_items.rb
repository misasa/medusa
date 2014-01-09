class CreateMeasurementItems < ActiveRecord::Migration
  def change
    create_table :measurement_items do |t|
      t.string :nickname
      t.text   :description
      t.string :display_in_html
      t.string :unit
      t.string :display_in_tex
    end
  end
end
