class AddWallToSurfaceLayer < ActiveRecord::Migration
  def change
    add_column :surface_layers, :wall, :boolean, default: false, null: false
  end
end
