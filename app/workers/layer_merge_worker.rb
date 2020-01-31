class LayerMergeWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker
  
    def perform(surface_layer_id, opts = {})
      surface_layer = SurfaceLayer.find(surface_layer_id)
      n = surface_layer.surface_images.count
      total n
      surface_layer.clean_tiles
      surface_layer.surface_images.reverse.each_with_index do |surface_image, index|
        if surface_image.wall
          at index, "#{surface_layer.name}/#{surface_image.image.name} ... (skipped)"
          next
        end
        at index, "#{surface_layer.name}/#{surface_image.image.name} ... #{index + 1}/#{n}"
        surface_image.merge_tiles(opts)
      end    
      at n, "Layer merging job for #{surface_layer.name} is done."
    end
  end
  