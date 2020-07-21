class TileWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(surface_image_id, opts = {})
    # Do something
    total 1
    surface_image = SurfaceImage.find(surface_image_id)
    at 0, "processing #{surface_image.image.name} ..."
    surface_image.clean_tiles
    surface_image.clean_warped_image
    surface_image.make_tiles(opts)
    layer = surface_image.surface_layer
    if layer && !surface_image.wall
      #at 0.8, "merging layer #{layer.name} ..."
      #layer.merge_tiles
      LayerMergeWorker.perform_async(layer.id)
    end
    at 1, "Tile making job for #{surface_image.image.name} is done."
  end
end
