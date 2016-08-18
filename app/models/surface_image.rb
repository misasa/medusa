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

  def to_region(opts = {})
  	tag = ""
  	#stroke_color = opts[:stroke_color] || 'green'
    surface.surface_images.each do |osurface_image|
      oimage = osurface_image.image
      next if oimage === image
      w = oimage.original_width
  	  h = oimage.original_height
  	  style = "stroke:rgb(0,255,0);stroke-width:10"
  	  corners = [[0,0], [w,0], [w,h], [0,h]]
      worlds = oimage.pixel_pairs_on_world(corners)
      pixels = image.world_pairs_on_pixel(worlds)
#      p oimage
#  	  p corners
#  	  p worlds
#  	  p pixels
      points = pixels.push(pixels[0]).map{|pix| pix.join(",")}.join(" ")
  	  #tag += %Q|<line x1="#{pixels[0][0]}" y1="#{pixels[0][1]}" x2="#{pixels[1][0]}" y2="#{pixels[1][1]}" style="#{style}"/>|
  	  #tag += %Q|<line x1="#{pixels[1][0]}" y1="#{pixels[1][1]}" x2="#{pixels[2][0]}" y2="#{pixels[2][1]}" style="#{style}"/>|
  	  #tag += %Q|<line x1="#{pixels[2][0]}" y1="#{pixels[2][1]}" x2="#{pixels[3][0]}" y2="#{pixels[3][1]}" style="#{style}"/>|
  	  #tag += %Q|<line x1="#{pixels[3][0]}" y1="#{pixels[3][1]}" x2="#{pixels[0][0]}" y2="#{pixels[0][1]}" style="#{style}"/>|  	  
      tag += %Q|<polyline points="#{points}" style="fill:none;fill-opacity:0.1;stroke:purple;stroke-width:5" data-spot="#{osurface_image.decorate.target_path}"/>|
  	end
#  	p tag
  	tag
  end

  def to_svg(opts = {})
    x = opts[:x] || 0
    y = opts[:y] || 0
    width = opts[:width] || image.original_width
    height = opts[:height] || image.original_height
    image_tag = %Q|<image xlink:href="#{image.path}" x="0" y="0" width="#{image.original_width}" height="#{image.original_height}" data-id="#{id}"/>|
    svg = image_tag
    svg += to_region
    surface.surface_images.each do |osurface_image|
      oimage = osurface_image.image
      #image_region
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
