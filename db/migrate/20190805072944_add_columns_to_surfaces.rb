class AddColumnsToSurfaces < ActiveRecord::Migration
  def change
    add_column :surfaces, :center_x, :float
    add_column :surfaces, :center_y, :float
    add_column :surfaces, :width, :float
    add_column :surfaces, :height, :float
  end
end
