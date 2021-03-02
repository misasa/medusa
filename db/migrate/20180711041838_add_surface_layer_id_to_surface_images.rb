class AddSurfaceLayerIdToSurfaceImages < ActiveRecord::Migration[4.2]
  def change
    add_reference :surface_images, :surface_layer, index: true, comment: "レイヤID"
  end
end
