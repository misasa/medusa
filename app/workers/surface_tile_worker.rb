class SurfaceTileWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(surface_id, opts = {})
    surface = Surface.find(surface_id)
    n = surface.surface_images.size
    total n
    surface.surface_layers.each do |surface_layer|
      surface_layer.clean_tiles
    end
    surface.surface_images.reverse.each_with_index do |surface_image, index|
      at index, "processing #{surface.name}/#{surface_image.image.name} ... (#{index + 1}/#{n})"
      surface_image.clean_tiles
      surface_image.clean_warped_image
      surface_image.make_tiles(opts)
      if surface_image.surface_layer
        surface_image.merge_tiles unless surface_image.wall
      end
    end
    at n, "Tile making job for #{surface.name} is done."
  end
end
