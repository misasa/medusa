class SurfaceTileWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(surface_id, opts = {})
    surface = Surface.find(surface_id)
    n = surface.surface_images.size
    total n
    surface.surface_images.each_with_index do |surface_image, index|
      at index, "processing #{surface.name}/#{surface_image.image.name} ... (#{index + 1}/#{n})"
      surface_image.clean_tiles
      surface_image.make_tiles(opts)
    end
    at n, "Tile making job for #{surface.name} is done."
  end
end
