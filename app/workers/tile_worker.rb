class TileWorker
  include Sidekiq::Worker

  def perform(surface_image_id, opts = {})
    # Do something
    surface_image = SurfaceImage.find(surface_image_id)
    surface_image.make_tiles(opts)
  end
end
