class SurfaceImage < ActiveRecord::Base
  belongs_to :surface
  belongs_to :image, class_name: AttachmentFile
  belongs_to :surface_layer
  acts_as_list :scope => :surface_id, column: :position

  validates :surface_layer, existence: true, allow_nil: true
  validate :check_image

  scope :wall, -> { where(wall: true) }
  scope :base, -> { where(wall: true) }
  scope :overlay, -> { where(wall: [false, nil])  }
  scope :not_base, -> { where.not(wall: true) }
#  scope :base, -> { where(position: minimum(:position)) }
#  scope :not_base, -> { where.not(position: minimum(:position)) }
  scope :not_belongs_to_layer, -> { where(surface_layer_id: nil) }

  def original_zoom_level
    return unless image
#    Math.log(surface.length/image.length_in_um * image.length/surface.tilesize, 2).ceil
    Math.log(surface.length/surface.tilesize * resolution, 2).ceil
  end

  def width
    return right - left if left && right
    return unless image
    image.width_in_um
  end

  def height
    return upper - bottom if upper && bottom
    return unless image
    image.height_in_um
  end

  def length
    l = width
    h = height
    l = h if h > l
    l
  end

  def resolution
    image.length/length
  end

  def tile_dir
    File.join(surface.map_dir,image.id.to_s)
  end

  def warped_image_path
    return unless image
    image.local_path(:warped)
  end

  def bounds
    return [left, upper, right, bottom] if left && upper && right && bottom
    return unless image
    image.bounds
  end

  def center
    return unless image
    left, upper, right, bottom = image.bounds
    [left + (right - left)/2.0, bottom + (upper - bottom)/2.0]
  end

  def tile_xrange(zoom)
    left, upper, right, bottom = image.bounds
    il = surface.tile_i_at(zoom, left)
    ir = surface.tile_i_at(zoom, right)
    il..ir
  end

  def tile_yrange(zoom)
    left, upper, right, bottom = image.bounds
    iu = surface.tile_j_at(zoom, upper)
    ib = surface.tile_j_at(zoom, bottom)
    iu..ib
  end

  def tiles_ij(zoom)
    center = surface.center
    length = surface.length
    box = [center[0] - length/2, center[1] + length/2, center[0] + length/2, center[1] - length/2]
    ibox = image.bounds
    tilesize = 256
    n = 2**zoom
    pix = tilesize * n
    length_per_pix = length/pix.to_f
    dum = length_per_pix*tilesize
    tiles_ij = []
    0.upto(n-1) do |i|
      0.upto(n-1) do |j|
        pbox = [tilesize*i, tilesize*j, tilesize*(i+1), tilesize*(j+1)]
        zleft = box[0] + dum*i
        zright = zleft + dum

        zupper = box[1] - dum*j
        zlower = zupper - dum
        cbox = [0,0,0,0]

        cbox[0] = (ibox[0] >= zleft && ibox[0] <= zright) ? ibox[0] : zleft
        cbox[2] = (ibox[2] >= zleft && ibox[2] <= zright) ? ibox[2] : zright

        

        cbox[1] = (ibox[1] <= zupper && ibox[1] >= zlower) ? ibox[1] : zupper
        cbox[3] = (ibox[3] <= zupper && ibox[3] >= zlower) ? ibox[3] : zlower

        tb = box_r(cbox, ibox)
        unless tb.any?{|r| r < 0 || r > 1}
          tiles_ij << [i,j]
        end
      end
    end
    tiles_ij
  end
  
  def box_r(ibox, box)
    bx = box[0]
    by = box[3]
    w = box[2] - box[0]
    h = box[1] - box[3]
    [(ibox[0] - bx)/w, 1 - (ibox[1] - by)/h, (ibox[2] - bx)/w, 1 - (ibox[3] - by)/h]
  end

  def make_tiles(options = {})
    return if image.affine_matrix.blank?
    make_warped_image unless File.exists?(warped_image_path)
    raise "#{warped_image_path} does not exists." unless File.exists?(warped_image_path)
    line = make_tiles_cmd(options)
    line.run
  end

  def clean_tiles(options = {})
    if Dir.exists?(tile_dir)
      line = Terrapin::CommandLine.new("rm", "-r :tile_dir", logger: logger)
      line.run(tile_dir: tile_dir)
    end
  end

  def clean_warped_image(options = {})
    if File.exists?(warped_image_path)
      line = Terrapin::CommandLine.new("rm", "-f :image_path", logger: logger)
      line.run(image_path: warped_image_path)  
    end
  end

  def make_warped_image(options = {})
    image.rotate
  end

  def make_tiles_cmd(options = {})
    maxzoom = options[:maxzoom] || original_zoom_level
    transparent = options.has_key?(:transparent) ? options[:transparent] : true
    transparent_color = options.has_key?(:transparent_color) ? options[:transparent_color] : false
    image_path = image.local_path(:warped)
    bs = image.bounds
    ce = surface.center
    if bs && bs.size == 4 && ce && ce.size == 2
      bounds_str = sprintf("[%.2f,%.2f,%.2f,%.2f]", bs[0], bs[1], bs[2], bs[3])
      center_str = sprintf("[%.2f,%.2f]", ce[0], ce[1])
      length_str = sprintf("%.2f", surface.length)
      cmd = "#{image_path} #{bounds_str} #{length_str} #{center_str} -o #{tile_dir} -z #{maxzoom}"
    end
    cmd += " -t" if transparent
    cmd += " #{transparent_color}" if transparent_color
    cmd
    line = Terrapin::CommandLine.new("make_tiles", cmd, logger: logger)
  end
  
  def tiles_each(zoom, &block)
    return unless image
    n = 2**zoom
    self.tile_yrange(zoom).each do |y|
      self.tile_xrange(zoom).each do |x|
        yield [x,y]
      end
    end
  end

  def spots
  	ss = []
    surface.surface_images.each do |osurface_image|
      oimage = osurface_image.image
      #image_region
      opixels = oimage.spots.map{|spot| [spot.spot_x, spot.spot_y]}
      worlds = oimage.pixel_pairs_on_world(opixels)
      pixels = image.world_pairs_on_pixel(worlds)
      oimage.spots.each_with_index do |spot, idx|
        spot.attachment_file_id = image.id
        spot.spot_x = pixels[idx][0]
        spot.spot_y = pixels[idx][1]
        ss << spot
      end
    end
  	ss
  end

  def to_region(opts = {})
  	tag = ""
  	#stroke_color = opts[:stroke_color] || 'green'
    surface.surface_images.each do |osurface_image|
      oimage = osurface_image.image
      #next if oimage === image
      w = oimage.original_width
  	  h = oimage.original_height
  	  style = "stroke:rgb(0,255,0);stroke-width:10"
  	  corners = [[0,0], [w,0], [w,h], [0,h]]
      worlds = oimage.pixel_pairs_on_world(corners)
      pixels = image.world_pairs_on_pixel(worlds)
#      p worlds
#      p pixels
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
#    x = opts[:x] || 0
#    y = opts[:y] || 0
#    width = opts[:width] || image.original_width
#    height = opts[:height] || image.original_height
    wl = 1000
    x_min = nil
    x_max = nil
    y_min = nil
    y_max = nil


    surface.surface_images.each_with_index do |osurface_image, idx|
      oimage = osurface_image.image
      next unless oimage
      next if oimage.affine_matrix.blank?
      w = oimage.original_width
      h = oimage.original_height
      style = "stroke:rgb(0,255,0);stroke-width:10"
      corners = [[0,0], [w,0], [w,h], [0,h]]
      worlds = oimage.pixel_pairs_on_world(corners)
      pixels = image.world_pairs_on_pixel(worlds)
      if idx == 0
        x_min = pixels[0][0]
        x_max = pixels[0][0]
        y_min = pixels[0][1]
        y_max = pixels[0][1]
      end
      pixels.each do |x,y|
        x_max = x if x_max < x
        x_min = x if x_min > x
        y_max = y if y_max < y
        y_min = y if y_min > y
      end
    end

    xl = x_max - x_min
    yl = y_max - y_min

    base_length = (xl > yl ? xl : yl)

    corners_on_world = image.pixel_pairs_on_world([[x_min, y_min],[x_max, y_min],[x_max, y_max]])
    corners_on_base = [[0,0],[xl,0],[xl,yl]]
    affine_base = MyTools::Affine.from_points_pair(corners_on_world, corners_on_base)
    canvas_width = xl
    canvas_height = yl

    image_xy = affine_base.transform_points(image.pixel_pairs_on_world([[0,0]]))[0]

    base_tag = %Q|<rect x="0" y="0" width="#{canvas_width}" height="#{canvas_height}" style="fill:skyblue;fill-opacity:0"/>|
    image_tag = %Q|<image xlink:href="#{image.path}" x="#{image_xy[0]}" y="#{image_xy[1]}" width="#{image.original_width}" height="#{image.original_height}" data-id="#{id}"/>|
    #svg = image_tag
    svg = ""
    svg += image_tag
    svg += base_tag
    #svg += to_region(affine_base)
    tag = ""
    surface.surface_images.each do |osurface_image|
      oimage = osurface_image.image
      next unless oimage
      next if oimage.affine_matrix.blank?
      w = oimage.original_width
      h = oimage.original_height
      style = "stroke:rgb(0,255,0);stroke-width:10"
      corners = [[0,0], [w,0], [w,h], [0,h]]
      worlds = oimage.pixel_pairs_on_world(corners)
      #pixels = image.world_pairs_on_pixel(worlds)
      pixels = affine_base.transform_points(worlds)
      points = pixels.push(pixels[0]).map{|pix| pix.join(",")}.join(" ")
      tag += %Q|<polyline points="#{points}" style="fill:none;fill-opacity:0.1;stroke:purple;stroke-width:5" data-spot="#{osurface_image.decorate.target_path}"/>|
    end
    svg += tag
    image_length = image.length
    image_length_world = image.length_in_um

    surface.surface_images.each do |osurface_image|
      oimage = osurface_image.image
      next unless oimage
      next if oimage.affine_matrix.blank?
      oimage_length = oimage.length
      oimage_length_world = oimage.length_in_um
      #image_region
      opixels = oimage.spots.map{|spot| [spot.spot_x, spot.spot_y]}
      worlds = oimage.pixel_pairs_on_world(opixels)
#      pixels = image.world_pairs_on_pixel(worlds)
      pixels = affine_base.transform_points(worlds)
      spot_tags = ""
      oimage.spots.each_with_index do |spot, idx|
        radius  = spot.radius_in_percent
        #p "length: #{oimage_length} pix #{oimage_length_world} um #{spot.radius_in_percent}%"
        radius_in_image = oimage_length * spot.radius_in_percent/100
        radius_in_world = oimage_length_world * spot.radius_in_percent/100
        #p "radius: #{radius_in_image} pix #{radius_in_world} um" 
        #p affine_base.transform_length(radius_in_image)
        radius_in_base = affine_base.transform_length(radius_in_world)
        #p radius_in_base
        stroke_width = spot.stroke_width
        #p oimage_length
        #p oimage.transform_length(oimage_length)
        #rr = oimage_length_world/image_length_world * oimage_length/image_length
        #rr = (oimage_length_world/image_length_world)
        #spot.radius_in_percent = radius * rr
        spot.stroke_width = stroke_width
      	spot.spot_x = pixels[idx][0]
      	spot.spot_y = pixels[idx][1]
        #p spot
        spot_tags += %Q|<circle #{spot.svg_attributes.merge(:r => "#{radius_in_base}").map { |k, v| "#{k}=\"#{v}\"" }.join(" ") }/>|
        #p spot_tags
        #svg += spot.to_svg
      end
      svg += spot_tags
    end
    svg
  end

  def as_json(options = {})
    super({ methods: [:spots, :bounds]}.merge(options))
  end

  private
  def check_image
	errors.add(:image_id, " must be image.") unless image.image?
  end
end
