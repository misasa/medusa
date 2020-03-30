class AddColumnToSurfaceLayer < ActiveRecord::Migration
  def change
    add_column :surface_layers, :max_zoom_level, :integer
  end
end
