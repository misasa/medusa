class AddTiledToSurfaceLayer < ActiveRecord::Migration[6.1]
  def change
    add_column :surface_layers, :tiled, :boolean, default:false, null: false
  end
end
