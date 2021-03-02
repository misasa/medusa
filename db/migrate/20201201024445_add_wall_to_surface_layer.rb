class AddWallToSurfaceLayer < ActiveRecord::Migration[4.2]
  def change
    add_column :surface_layers, :wall, :boolean, default: false, null: false
  end
end
