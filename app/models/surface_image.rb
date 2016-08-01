class SurfaceImage < ActiveRecord::Base
  belongs_to :surface
  belongs_to :image, class_name: AttachmentFile 
  acts_as_list :scope => :surface_id, column: :position

  validate :check_image
  
  def spots
  	ss = []
  	surface.images.each do |image|
  	  ss.concat(image.spots)
  	end
  	ss
  end

  def to_svg(opts = {})
    x = opts[:x] || 0
    y = opts[:y] || 0
    width = opts[:width] || image.original_width
    height = opts[:height] || image.original_height
    image_tag = %Q|<image xlink:href="#{image.path}" x="0" y="0" width="#{image.original_width}" height="#{image.original_height}" data-id="#{id}"/>|
    svg = image_tag
    surface.surface_images.each do |osurface_image|
      oimage = osurface_image.image
      opixels = oimage.spots.map{|spot| [spot.spot_x, spot.spot_y]}
      worlds = oimage.pixel_pairs_on_world(opixels)
      pixels = image.world_pairs_on_pixel(worlds)
      oimage.spots.each_with_index do |spot, idx|
      	spot.spot_x = pixels[idx][0]
      	spot.spot_y = pixels[idx][1]
        svg += spot.to_svg
      end
    end
    #spots.inject(image_tag) { |svg, spot| svg + spot.to_svg }
#    surface.surface_images.each do |image|
#    	spots = image.spots
#    	spots.inject(image_tag){ |svg, spot| svg + spot.to_svg }
#    end
     svg
  end


  private
  def check_image
	errors.add(:image_id, " must be image.") unless image.image?
  end
end
