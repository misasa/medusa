class Surface < ActiveRecord::Base
  include HasRecordProperty

  paginates_per 10

  has_many :surface_images, :dependent => :destroy, :order => ("position ASC")
  has_many :images, through: :surface_images
  has_many :surface_layers, :dependent => :destroy, :order => ("priority ASC")
  has_many :spots, through: :images
  has_many :direct_spots, class_name: "Spot", foreign_key: :surface_id

  accepts_nested_attributes_for :surface_images

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

  def specimens
    sps = []
    images.each do |image|
      next unless image
      sps.concat(image.specimens) if image.specimens
    end
    sps.compact.uniq
  end

  def first_image
    surface_image = surface_images.order('position ASC').first
    surface_image.image if surface_image
  end

  def center
    return if bounds.blank?
    left, upper, right, bottom = bounds
    x = left + (right - left)/2
    y = bottom + (upper - bottom)/2
    [x, y]
  end

  def width
    return if bounds.blank?
    left, upper, right, bottom = bounds
    right - left
  end

  def height
    return if bounds.blank?
    left, upper, right, bottom = bounds
    upper - bottom
  end

  def length
    return if bounds.blank?
    l = width
    l = height if height > width
    l
  end

  def bounds
    return Array.new(4) { 0 } if globe? || images.blank?
    left,upper,right,bottom = images[0].bounds
    images.each do |image|
      next if image.bounds.blank?
      l,u,r,b = image.bounds
      left = l if l < left
      upper = u if u > upper
      right = r if r > right
      bottom = b if b < bottom
    end
    [left, upper, right, bottom]
  end

  def bbox
    [center[0] - length/2, center[1] + length/2, center[0] + length/2, center[1] - length/2]
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

  private

  def make_tile_of_added_image(image)
    return if image.affine_matrix.blank?
    index = surface_images.find_index { |surface_image| surface_image.image_id == image.id }
    return unless index
    TileWorker.perform_async(surface_images[index].id, :transparent => index > 0)
  end
end
