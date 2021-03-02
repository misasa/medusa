class AddVisibleToSurfaceLayer < ActiveRecord::Migration[4.2]
  def change
    add_column :surface_layers, :visible, :boolean, default: true, null: false
  end
end
