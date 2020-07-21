class AddVisibleToSurfaceLayer < ActiveRecord::Migration
  def change
    add_column :surface_layers, :visible, :boolean, default: true, null: false
  end
end
