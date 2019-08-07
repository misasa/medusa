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
    at 1, "Tile making job for #{surface_image.image.name} is done."
  end
end
