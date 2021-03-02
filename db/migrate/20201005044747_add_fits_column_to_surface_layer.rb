class AddFitsColumnToSurfaceLayer < ActiveRecord::Migration[4.2]
  def change
    add_column :surface_layers, :color_scale, :string
    add_column :surface_layers, :display_min, :float
    add_column :surface_layers, :display_max, :float
  end
end
