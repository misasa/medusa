class AddColumnsToSurfaces < ActiveRecord::Migration[4.2]
  def change
    add_column :surfaces, :center_x, :float
    add_column :surfaces, :center_y, :float
    add_column :surfaces, :width, :float
    add_column :surfaces, :height, :float
  end
end
