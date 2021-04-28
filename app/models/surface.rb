require 'matrix'
class Surface < ApplicationRecord
  include HasRecordProperty

  paginates_per 10
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings

  has_many :specimen_surfaces, dependent: :destroy
  has_many :specimens, through: :specimen_surfaces
  has_many :surface_images, -> { order('position DESC') }, dependent: :destroy
  has_many :calibrated_surface_images, -> { calibrated }, class_name: 'SurfaceImage'
  has_many :uncalibrated_surface_images, -> { uncalibrated }, class_name: 'SurfaceImage'
  has_many :not_belongs_to_layer_surface_images, -> { not_belongs_to_layer }, class_name: 'SurfaceImage'
  has_many :top_surface_images, -> { top }, class_name: 'SurfaceImage'
  has_many :base_surface_images, -> { base }, class_name: 'SurfaceImage'
  has_many :uncalibrated_top_surface_images, -> { uncalibrated_top }, class_name: 'SurfaceImage'

  has_many :wall_surface_images, -> { wall }, class_name: 'SurfaceImage'
  has_many :fits_file_surface_images, -> { fits_file }, class_name: 'SurfaceImage'

  has_many :images, through: :surface_images
  has_many :fits_files, -> { fits_files }, through: :surface_images, source: :image
  has_many :surface_layers, -> { order('priority DESC') }, dependent: :destroy
  has_many :wall_surface_layers, -> { wall }, class_name: 'SurfaceLayer'
#  has_many :spots, through: :images
#  has_many :spots, class_name: "Spot", foreign_key: :surface_id
  has_many :direct_spots, class_name: "Spot", foreign_key: :surface_id
  accepts_nested_attributes_for :surface_images

  before_save :check_image_bounds
  #after_save :make_map

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true

  def map_dir
    File.join(Rails.public_path,"system/maps",global_id)
  end

  def publish!
    objs = [self]
    objs.concat(self.surface_images.map(&:image))
    objs.compact!
    objs.each do |obj|
      obj.published = true if obj
      obj.save
    end
  end

  def make_map(opts = {})
    #maxzoom = opts[:maxzoom] || 5
    surface_images.order("position ASC").each_with_index do |surface_image, index|
      options = opts
      options.merge!(:transparent => true) if index > 0
      TileWorker.perform_async(surface_image.id, options)
      #surface_image.make_tiles(opts.merge({:transparent => true})) if index > 0
    end
  end

  def spots
    Spot.preload(:record_property, :attachment_file, {target_property: [{analysis: [:chemistries]}, {specimen: {analyses: [:chemistries]} }]}).where("surface_id = ? or attachment_file_id IN (?)", self.id, self.image_ids)
  end

  def target_uids
    spots.pluck(:target_uid)
  end

  def spot_specimens
    Specimen.eager_load(:record_property).where(record_property: {global_id: target_uids})
  end

  def spot_analyses
    Analysis.eager_load(:record_property).where(record_property: {global_id: target_uids})
  end

#  def spots
#    ss = []
#    ss.concat(direct_spots) unless direct_spots.blank?
#    ss.concat(indirect_spots) unless indirect_spots.blank?
#    ss
#  end

  def indirect_spots_old
    ss = []
    image = first_image
    surface_images.each do |osurface_image|
      oimage = osurface_image.image
      next unless oimage
      next if oimage.affine_matrix.blank?
      #image_region
      opixels = oimage.spots.map{|spot| [spot.spot_x, spot.spot_y]}
      worlds = oimage.pixel_pairs_on_world(opixels)
      pixels = image.world_pairs_on_pixel(worlds)
      oimage.spots.each_with_index do |spot, idx|
      	spot.attachment_file_id = image.id
        spot.spot_x = pixels[idx][0]
        spot.spot_y = pixels[idx][1]
        spot.world_x = worlds[idx][0]
        spot.world_y = worlds[idx][1]
        ss << spot
      end
    end
    ss
  end

  def candidate_specimens
    sps = []
    images.each do |image|
      next unless image
      sps.concat(image.specimens) if image.specimens
    end
    sps.compact.uniq
  end

  def first_image
    surface_image = surface_images.first
    surface_image.image if surface_image
  end

  def center
    x = 0.0
    y = 0.0
    #x, y = image_bounds_center if image_bounds_center
    x = center_x unless center_x.blank?
    y = center_y unless center_y.blank?
    [x,y]
  end

  def image_bounds_center
    return if image_bounds.blank? || image_bounds.include?(nil)
    left, upper, right, bottom = image_bounds
    x = left + (right - left)/2
    y = bottom + (upper - bottom)/2
    [x, y]
  end

  def image_bounds_width
    return if image_bounds.blank?
    left, upper, right, bottom = image_bounds
    return if [right,left].include?(nil)
    right - left
  end

  def image_bounds_height
    return if image_bounds.blank?
    left, upper, right, bottom = image_bounds
    return if [upper, bottom].include?(nil)
    upper - bottom
  end

  def image_bounds_length
    return if [image_bounds_width, image_bounds_height].include?(nil)
    l = image_bounds_width
    l = image_bounds_height if image_bounds_height > image_bounds_width
    l
  end

  def length
    if width.blank? && height.blank?
      l = 100000
      l = image_bounds_length if image_bounds_length
    elsif width.blank?
      l = height
    else
      l = width
    end

    l = width if width > l unless width.blank?
    l = height if height > l unless height.blank?
    l
  end

  def length=(_length)
    r = _length.to_f/self.length
    scale(r)
  end
  
  def image_bounds
    return Array.new(4) { nil } if globe? || surface_images.blank?
    left,upper,right,bottom = [nil,nil,nil,nil]
    surface_images.each do |s_image|
      next if s_image.bounds.blank? || s_image.bounds.include?(nil)
      l,u,r,b = s_image.bounds
      left = l if (left.blank? || l < left)
      upper = u if (upper.blank? || u > upper)
      right = r if (right.blank? || r > right)
      bottom = b if (bottom.blank? || b < bottom)
    end
    [left, upper, right, bottom]
  end

  def bbox
    [center[0] - length/2, center[1] + length/2, center[0] + length/2, center[1] - length/2]
  end

  def tilesize
    256
  end

  def ntiles(zoom)
    2**zoom
  end

  def length_per_pix(zoom)
    pix = tilesize * ntiles(zoom)
    length/pix.to_f
  end

  def affine_matrix_for_map
    return if bbox.blank?
    left, top, _ = bbox
    width = image_bounds_width unless width
    height = image_bounds_height  unless height
    return if [left, top, length, width, height].include?(nil)
    x = tilesize
    y = tilesize
    len = length
    #puts "len: #{len} left: #{left} top: #{top} x: #{x} y: #{y}"
    x_offset = (len - width) / 2
    y_offset = (len - height) / 2
    Matrix[
      [256 / len, 0, (x_offset - left) * 256 / len],
      [0, -256 / len, (y_offset + top) * 256 / len],
      [0, 0, 1]
    ]
  end
 
  def initial_corners_for(image, opts = {})
    ratio = length/image.length/4
    width = image.width * ratio
    height = image.height * ratio
    cx, cy = center
    l = cx - width/2
    r = cx + width/2
    u = cy + height/2
    b = cy - height/2
    return [[l,u],[r,u],[r,b],[l,b]]
  end

  def coords_on_map(world_coords)
    flag_single = true if world_coords[0].is_a?(Float)
    if flag_single
      world_coords = [world_coords]
    end
    n = Matrix.columns(world_coords)
    n = Matrix.rows(n.to_a << Array.new(world_coords.size, 1))
    matrix = affine_matrix_for_map
    nn = matrix * n
    coords = []
    nn.t.to_a.each do |r|
      coords << [r[0],r[1]]
    end

    flag_single ? coords[0] : coords
  end

  def coords_on_world(map_coords)
    flag_single = true if map_coords[0].is_a?(Float)
    if flag_single
      map_coords = [map_coords]
    end
    n = Matrix.columns(map_coords)
    n = Matrix.rows(n.to_a << Array.new(map_coords.size, 1))
    matrix = affine_matrix_for_map.inv
    nn = matrix * n
    coords = []
    nn.t.to_a.each do |r|
      coords << [r[0],r[1]]
    end

    flag_single ? coords[0] : coords
  end



  def tile_ij_at(zooms, x, y)
    flag_single = true if zooms.is_a?(Integer)
    if flag_single
      zooms = [zooms]
    end
    left, upper, right, bottom = bbox
    dx = x - left
    dy = upper - y

    ijs = []
    zooms.each do |zoom|
      n = ntiles(zoom)
      lpp = length_per_pix(zoom)

      ii = dx/(lpp * tilesize)
      jj = dy/(lpp * tilesize)

      i = ii.floor
      i = 0 if (i < 0)
      i = n - 1 if i > n - 1
      j = jj.floor
      j = 0 if j < 0
      j = n - 1 if j > (n - 1)
      ijs << [i,j]
    end
    if flag_single 
      ijs = ijs[0]
    end
    ijs
  end

  def tile_i_at(zoom, x)
    n = ntiles(zoom)
    left, upper, right, bottom = bbox
    delta = x - left
    #delta = 0.0 if x - left < 1E-5
    ii = delta/(length_per_pix(zoom) * tilesize)
    i = ii.floor
    i = 0 if (i < 0)
    i = n - 1 if i > n - 1
    i
  end


  def tile_j_at(zoom, y)
    n = ntiles(zoom)
    left, upper, right, bottom = bbox
    delta = upper - y
    jj = delta/(length_per_pix(zoom) * tilesize)
    j = jj.floor
    j = 0 if j < 0
    j = n - 1 if j > (n - 1)
    j
  end

  def tile_at(zoom, xy)
    tile_ij_at(zoom, xy[0],xy[1])
  end

#  def as_json(options = {})
#    super({ methods: [:global_id, :image_ids, :globe, :center, :length, :bounds] }.merge(options))
#  end

  def pml_elements
    if globe?
      places = Place.all
      array = []
      array << places.map(&:specimens)
      array << places.map(&:bibs)
      array = array.flatten.compact.uniq
      array = array.map(&:pml_elements).flatten.compact.uniq
      array
    else
      super
    end
  end


  def reorder_images
    id_positions = surface_images.pluck(:id, :position)
    first_position = surface_images.first.position
    surface_images.each{|surface_image|
      tmp_position = first_position + surface_image.position
      surface_image.update_attribute(:position, tmp_position)
    }
    surface_images.reverse.each_with_index{|surface_image, index|
      surface_image.update_attribute(:position, index + 1)
    }
  end
  def scale(r = 1.0)
      affine_matrix = "[[#{r},0.0,0.0],[0.0,#{r},0.0],[0.0,0.0,1.0]]"
      surface_spots = spots.where(attachment_file_id: nil)
      if !surface_spots.blank?
        spots_str = surface_spots.map{|spot| [spot.world_x,spot.world_y]}.to_s.gsub(" ","")
        cmd_args = "--matrix=" + affine_matrix + " " + spots_str
        line = Terrapin::CommandLine.new("transform_points", cmd_args, logger: logger)
        line.run
        _spots_str = line.output.output.chomp
        _spots_str.gsub("[","").gsub("]]","").gsub("],","|").split("|").each_with_index do |_spot_str, index|
          spot = surface_spots[index]
          spot.world_x, spot.world_y = _spot_str.split(",").map(&:to_f)
          spot.radius_in_um = spot.radius_in_um * r
          spot.save
        end
      end
      surface_images.each do |surface_image|
      image = surface_image.image
      next unless image
      points = surface_image.corners_on_world_str
      if points
        cmd_args = "--matrix=" + affine_matrix + " " + points
        line = Terrapin::CommandLine.new("transform_points", cmd_args, logger: logger)
        line.run
        _corners_on_world_str = line.output.output.chomp
        line = Terrapin::CommandLine.new("H_from_points", "#{surface_image.corners_on_image_str} #{_corners_on_world_str} -f yaml", logger: logger)
        line.run
        _out = line.output.output.chomp
        a = YAML.load(_out)
        image.affine_matrix = a.flatten
        image.save
        image.spots.each do |spot|
          spot.world_x, spot.world_y = spot.spot_world_xy
          spot.radius_in_um = spot.radius_in_um * r
          spot.save
        end
      end
    end
  end  

  private

  def check_image_bounds
    self.center_x, self.center_y = image_bounds_center if image_bounds_center
    self.width = image_bounds_width if image_bounds_width
    self.height = image_bounds_height if image_bounds_height
  end

  def make_tile_of_added_image(image)
    return if image.affine_matrix.blank?
    index = surface_images.find_index { |surface_image| surface_image.image_id == image.id }
    return unless index
    TileWorker.perform_async(surface_images[index].id, :transparent => index > 0)
  end

end
