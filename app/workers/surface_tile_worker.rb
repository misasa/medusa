class SurfaceTileWorker < BaseWorker
#  include Sidekiq::Worker

  def perform(surface_id, opts = {})
    surface = Surface.find(surface_id)
    n = surface.surface_images.size
    n_pos = surface.surface_images.pluck(:position).uniq.count 

    if n_pos < n
      at 0, "reordering images..."
      surface.reorder_images
    end
    n = surface.base_surface_images.count + surface.top_surface_images.count + surface.surface_layers.count
    total n
    surface.surface_images.each do |surface_image|
      image = surface_image.image
      next unless image
      left,upper,right,bottom = image.bounds
      surface_image.update(left: left, upper: upper, right: right, bottom: bottom)
    end
    surface.save
    index = 1
    surface.wall_surface_images.reverse.each_with_index do |surface_image, idx|
      at index, "processing #{surface.name}/#{surface_image.image.name} ... (#{index + 1}/#{n})"
      surface_image.clean_tiles
      line = surface_image.make_tiles_cmd(opts)
      next unless line
      logger.info(line.command)
      line.run
      index += 1
    end

    surface.surface_layers.reverse.each_with_index do |surface_layer, idx|
      at index, "processing #{surface.name}/#{surface_layer.name} ... (#{index + 1}/#{n})"
      surface_layer.clean_tiles
      surface_layer.update_attribute(:tiled, false)
      surface_layer.generate_pngs
      line = surface_layer.make_tiles_cmd(opts)
      next unless line
      logger.info(line.command)
      line.run
      surface_layer.update_attribute(:tiled, true)
      index += 1
    end

    surface.top_surface_images.reverse.each_with_index do |surface_image, idx|
      at index, "processing #{surface.name}/#{surface_image.image.name} ... (#{index + 1}/#{n})"
      surface_image.clean_tiles
      if surface_image.image.fits_file?
        surface_image.image.fits2png
      end  
      line = surface_image.make_tiles_cmd(opts)
      next unless line
      logger.info(line.command)
      line.run
      index += 1
    end

    at n, "Tile making job for #{surface.name} is done."
  end
end
