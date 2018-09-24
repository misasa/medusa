class AddSurfaceLayerIdToSurfaceImages < ActiveRecord::Migration
  def change
    add_reference :surface_images, :surface_layer, index: true, comment: "レイヤID"
  end
end
