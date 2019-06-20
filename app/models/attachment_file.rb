require 'matrix'
class AttachmentFile < ActiveRecord::Base
  include HasRecordProperty

  has_attached_file :data,
    styles: { thumb: "160x120>", tiny: "50x50"},
    path: ":rails_root/public/system/:class/:id_partition/:basename_with_style.:extension",
    url: "#{Rails.application.config.relative_url_root}/system/:class/:id_partition/:basename_with_style.:extension",
    restricted_characters: /[&$+,\/:;=?<>\[\]\{\}\|\\\^~%# ]/

  alias_attribute :name, :data_file_name

  has_many :spots, dependent: :destroy, inverse_of: :attachment_file
  has_many :attachings, dependent: :destroy
  has_many :specimens, -> { order(:name) }, through: :attachings, source: :attachable, source_type: "Specimen"
  has_many :places, through: :attachings, source: :attachable, source_type: "Place"
  has_many :boxes, -> { order(:name) }, through: :attachings, source: :attachable, source_type: "Box"
  has_many :bibs, through: :attachings, source: :attachable, source_type: "Bib"
  has_many :analyses, through: :attachings, source: :attachable, source_type: "Analysis"
  has_many :surface_images, foreign_key: :image_id
  has_many :surfaces, :through => :surface_images, dependent: :destroy

  attr_accessor :path
  after_post_process :save_geometry
#  after_save :rotate
  after_save :check_affine_matrix
  after_save :update_spots_world_xy
  after_update :rename_attached_files_if_needed

  serialize :affine_matrix, Array

  validates :data, presence: true

  def path(style = :original)
    File.exists?(data.path(style)) ? data.url(style) : data.url(:original)
  end

  def as_json(options = {})
    super({:methods => [:bounds, :corners_on_world, :width_in_um, :height_in_um, :original_path, :thumbnail_path, :tiny_path, :global_id]}.merge(options))
  end

  def original_path
    path
  end


  def thumbnail_path
    path(:thumb)
  end

  def tiny_path
    path(:tiny)
  end

  def data_fingerprint
    self.md5hash
  end

  def data_fingerprint=(md5Hash)
    self.md5hash=md5Hash
  end

  def save_geometry
    self.original_geometry = Paperclip::Geometry.from_file(data.queued_for_write[:original]).to_s rescue nil
  end

  def warped_path
    _path = data.path
    dirname = File.dirname(_path)
    basename = File.basename(_path, ".*")
    File.join([dirname, basename + "_warped.png"])
    #File.join([Rails.root.to_s, "public", dirname, basename + "_warped.png"])
  end
 
  def warped_url
    _url = data.url
    dirname = File.dirname(_url)
    basename = File.basename(_url, ".*")
    File.join([dirname, basename + "_warped.png"])
    #File.join([Rails.root.to_s, "public", dirname, basename + "_warped.png"])

  end

  def local_path(style = :original)
    _path = data.path(style)
    if style == :warped
      _path = warped_path
    end
    _path.sub(/\?\d+$/,"")
  end

  def check_affine_matrix
    if affine_matrix_changed?
      b, a = affine_matrix_change
      if a.instance_of?(Array) && a.size == 9
        RotateWorker.perform_async(id) unless a == [1,0,0,0,1,0,0,0,1]
        if surface_images.present?
          p bounds
          left,upper,right,bottom = bounds
          surface_images.each do |surface_image|
            surface_image.update(left: left, upper: upper, right: right, bottom: bottom)
            TileWorker.perform_async(surface_image.id)
          end
        end
      end
    end
  end

  def rotate
    logger.info("in rotate")
    raise "bounds does not exist." unless bounds
    raise "#{local_path} does not exist." unless File.exists?(local_path)
    raise "#{local_path} is not a image."unless image?
    logger.info("generating...")
    left, upper, right, bottom = bounds
    logger.info(bounds)
    bb = bounds
    b_w = right - left
    b_h = upper - bottom
    p_um = pixels_per_um
    new_geometry = [(b_w * p_um).ceil, (b_h * p_um).ceil]
    corners_on_new_image = []
    corners_on_world.each do |corner|
      dx = corner[0] - left
      dy = upper - corner[1]
      pixs = [(dx/b_w*new_geometry[0]).to_int, (dy/b_h*new_geometry[1]).to_int]
      corners_on_new_image << pixs
    end
    image_1 = local_path
    image_2 = local_path(:warped)
    png = ChunkyPNG::Image.new(new_geometry[0], new_geometry[1])
    png.save(image_2)
    array_str = corners_on_new_image.to_s.gsub(/\s+/,"")
    
    line = Terrapin::CommandLine.new("image_in_image", "#{image_1} #{image_2} #{array_str} -o #{image_2}", logger: logger)
    line.run
  end

 
  def update_spots_world_xy
    return unless affine_matrix_changed?
    spots.each(&:save!)
  end

  def rename_attached_files_if_needed
    return if !name_changed? || data_updated_at_changed?
    logger.info("renameing...")
    (data.styles.keys+[:original]).each do |style|
      path = data.path(style)
      dirname = File.dirname(path)
      extname = File.extname(path)
      basename = File.basename(data_file_name,'.*')
      old_basename = File.basename(data_file_name_was, '.*')
      old_path = File.join(dirname, File.basename(path).sub(basename, old_basename))
      logger.info("rename_attached_files: #{old_path} ->  #{path}")
      FileUtils.mv(old_path, path)
    end
  end

  def pdf?
    !(data_content_type =~ /pdf$/).nil?
  end

  def image?
    !(data_content_type =~ /^image.*/).nil?
  end

  def original_width
    return unless original_geometry
    original_geometry.split("x")[0].to_i
  end

  def original_height
    return unless original_geometry
    original_geometry.split("x")[1].to_i
  end

 def width(style = :original)
    if style == :original && original_geometry
      return original_width
    else
      width_from_file(style)
    end
  end

 def height(style = :original)
    if style == :original && original_geometry
      return original_height
    else
      height_from_file(style)
    end
  end

  def length
    return unless self.image?
    if width && height
      return width >= height ? width : height
    else
      return nil
    end
  end

  def pixels_on_image(x, y)
    return if affine_matrix.blank?
    image_xy2image_coord(pixel2percent(x), pixel2percent(y))    
  end

  def pixels_per_um
    um = width_in_um
    return unless um
    width/um
  end

  def pixels_on_world(x, y)
    im = pixels_on_image(x, y)
    affine_transform(*im)
  end

  def percent2pixel(percent)
    return unless self.image?
    return unless self.length && self.length > 0
    return self.length.to_f * percent / 100
  end

  def pixel2percent(pix)
    return unless self.image?
    return unless self.length && self.length > 0
    return pix/self.length.to_f * 100
  end

  def width_on_stage
    return if affine_matrix.blank?
    transform_length(width / length.to_f * 100)
  end

  def transform_length(l, type = :xy2world)
    src_points = [[0,0],[l,0]]
    dst_points = transform_points(src_points, type)
    return Math::sqrt((dst_points[0][0] - dst_points[1][0]) ** 2 + (dst_points[0][1] - dst_points[1][1]) ** 2)
  end

 def affine_matrix_in_string
    a = affine_matrix
    return unless a
    str = ""
    a.in_groups_of(3, false) do |row|
      vals = Array.new
      row.each do |val|
        vals.push sprintf("%.3e",val) if val
      end
      str += vals.join(',')
      str += ';'
    end
    "[#{str.sub(/\;$/,'')}]"
  end

  def affine_matrix_in_string=(str)
    str = str.gsub(/\[/,"").gsub(/\]/,"").gsub(/\;/,",").gsub(/\s+/,"")
    tokens = str.split(',')
    vals = tokens.map{|token| token.to_f}
    vals.concat([0,0,1]) if vals.size == 6
    if vals.size == 9
      self.affine_matrix = vals
    end
  end

  def affine_transform(xs, ys)
    a = affine_matrix
    return unless a
    return if a.blank?
    xyi = Array.new
    xi = a[0] * xs + a[1] * ys + a[2]
    yi = a[3] * xs + a[4] * ys + a[5]
    return [xi, yi]
  end

  def corners_on_image
    return if affine_matrix.blank?
    [image_xy2image_coord(0,0), image_xy2image_coord(x_max,0), image_xy2image_coord(x_max,y_max), image_xy2image_coord(0,y_max)]
  end

  def corners_on_world
    return if affine_matrix.blank?
    a, b, c, d = corners_on_image
    [affine_transform(*a),affine_transform(*b),affine_transform(*c),affine_transform(*d)]
  end
  
  def bounds
    return Array.new(4) { 0 } if affine_matrix.blank?
    cs = corners_on_world
    xi, yi = cs[0]
    left = xi
    right = xi
    upper = yi
    bottom = yi
    corners_on_world.each do |corner|
      x, y = corner
      left = x if x < left
      right = x if x > right
      bottom = y if y < bottom
      upper = y if y > upper
    end
    [left,upper,right,bottom]
  end

  def width_in_um
    return if affine_matrix.blank?
    ps = image_xy2image_coord(0,0)
    pe = image_xy2image_coord(x_max,0)
    p1 = affine_transform(*ps)
    p2 = affine_transform(*pe)
    dx = p1[0] - p2[0]
    dy = p1[1] - p2[1]
    return Math.sqrt(dx * dx + dy * dy)
  end

  def height_in_um
    return if affine_matrix.blank?

    ps = image_xy2image_coord(0,0)
    pe = image_xy2image_coord(0,y_max)
    p1 = affine_transform(*ps)
    p2 = affine_transform(*pe)
    dx = p1[0] - p2[0]
    dy = p1[1] - p2[1]
    return Math.sqrt(dx * dx + dy * dy)
  end

  def length_in_um
    w = width_in_um
    h = height_in_um
    if w && h
      w > h ? w : h
    else
    end
  end

  def to_svg(opts = {})
    x = opts[:x] || 0
    y = opts[:y] || 0
    width = opts[:width] || original_width
    height = opts[:height] || original_height


    image = %Q|<image xlink:href="#{path}" x="0" y="0" width="#{original_width}" height="#{original_height}" data-id="#{id}"/>|
    spots.inject(image) { |svg, spot| svg + spot.to_svg }
  end

  def pixel_pairs_on_world(pairs)
    xys = pairs.map{|pa| pixels_on_image(*pa)}
    transform_points(xys)
  end

  def world_pairs_on_pixel(pairs)
    return if affine_matrix.blank? || pairs.blank?
    xys = transform_points(pairs, :world2xy)
    xys.map{|x, y| image_coord2xy(x, y).map{|z| percent2pixel(z)} }
  end

  def calibration_points_on_pixel
    [
      [0, 0],
      [original_width, 0],
      [original_width, original_height]
    ]
  end

  def calibration_points_on_world
    return if affine_matrix.blank?
    pixel_pairs_on_world(calibration_points_on_pixel)
  end

  private

  def x_max
      width.to_f/length.to_f * 100 if width
  end

  def y_max
      height.to_f/length.to_f * 100 if height
  end

  def image_xy2image_coord(x,y)
    center_point = [x_max/2, y_max/2]
    [x - center_point[0], center_point[1] - y]
  end

  def image_coord2xy(ix,iy)
    center_point = [x_max/2, y_max/2]
    [ix + center_point[0], center_point[1] - iy]
  end


  def array_to_matrix(array)
    m = Matrix[array[0..2],array[3..5],array[6..8]]
    return m
  end

  def affine_xy2world
    array_to_matrix(affine_matrix)
  end

  def affine_world2xy
    affine_xy2world.inv
  end

  def transform_points(points, type = :xy2world)
    case type
    when :world2xy
      affine = affine_world2xy
    else
      affine = affine_xy2world
    end

    num_points = points.size
    src_points = Matrix[points.map{|p| p[0]}, points.map{|p| p[1]}, Array.new(points.size, 1.0)]
    warped_points = (affine * src_points).to_a

    xt = warped_points[0]
    yt = warped_points[1]
    dst_points = []
    num_points.times do |i|
      dst_points << [xt[i], yt[i]]
    end
    return dst_points
  end
  
end
