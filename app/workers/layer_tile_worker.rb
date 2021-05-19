class LayerTileWorker < BaseWorker
#  include Sidekiq::Worker
#  include Sidekiq::Status::Worker

  def perform(surface_layer_id, opts = {})
    surface_layer = SurfaceLayer.find(surface_layer_id)
    surface = surface_layer.surface
    n = surface_layer.surface_images.count
    n_pos = surface_layer.surface_images.pluck(:position).uniq.count 
    total n
    if n_pos < n
      at 0, "reordering images..."
      surface.reorder_images
    end
    surface_layer.clean_tiles
    surface_layer.generate_pngs
    line = surface_layer.make_tiles_cmd(opts)
    logger.info(line.command)
    line.run
    at n, "Tile making job for #{surface_layer.name} is done."
  end

  def perform_old(surface_layer_id, opts = {})
    surface_layer = SurfaceLayer.find(surface_layer_id)
    surface = surface_layer.surface
    n = surface_layer.surface_images.count
    n_pos = surface_layer.surface_images.pluck(:position).uniq.count 
    total n
    if n_pos < n
      at 0, "reordering images..."
      surface.reorder_images
    end
    surface_layer.clean_tiles
    surface_layer.surface_images.reverse.each_with_index do |surface_image, index|
      if surface_image.wall
        at index, "#{surface_layer.name}/#{surface_image.image.name} ... (skipped)"
        next
      end
      at index, "#{surface_layer.name}/#{surface_image.image.name} ... #{index + 1}/#{n}"
      logger.info("#{surface_layer.name}/#{surface_image.image.name} ... #{index + 1}/#{n}")
      logger.info("clean tiles...")
      surface_image.clean_tiles
      logger.info("clean warped_image...")
      surface_image.clean_warped_image
      logger.info("make tiles...")
      surface_image.make_tiles(opts)
      logger.info("merge tiles...")
      surface_image.merge_tiles(opts)
      logger.info("completed")
    end    
    at n, "Tile making job for #{surface_layer.name} is done."
  end
end
