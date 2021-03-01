class AddColumnToSurfaceLayer < ActiveRecord::Migration[4.2]
  def change
    add_column :surface_layers, :max_zoom_level, :integer
  end
end
