class SurfaceLayer < ActiveRecord::Base
  belongs_to :surface
  has_many :surface_images, :dependent => :nullify, :order => ("position DESC")
  has_many :wall_surface_images, -> { wall }, class_name: 'SurfaceImage'
  has_many :overlay_surface_images, -> { overlay }, class_name: 'SurfaceImage'
  has_many :images, through: :surface_images
  acts_as_list :scope => :surface_id, column: :priority

  validates :surface_id, presence: true
  validates :surface, existence: true, allow_nil: true
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :surface_id }
  validates :opacity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :priority, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :max_zoom_level, allow_nil: true, allow_blank: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 14}
  def self.max_priority
    all.maximum(:priority) || 0
  end

  def bounds
    overlay_images = overlay_surface_images.map{|s_i| s_i.image if s_i.image.bounds && s_i.image.bounds.all?{|e| !e.nil? }}.compact
    return Array.new(4) { 0 } if surface.globe? || overlay_images.blank?
    left,upper,right,bottom = overlay_images[0].bounds
    overlay_images.each do |image|
      next if image.bounds.blank?
      l,u,r,b = image.bounds
      left = l if l && l < left
      upper = u if u && u > upper
      right = r if r && r > right
      bottom = b if b && b < bottom
    end
    [left, upper, right, bottom]
  end
 
  def tile_dir
    File.join(surface.map_dir, "layers","#{id}")
  end

  def tiled?
    File.exist?(tile_dir)
  end

  def original_zoom_level
  #  surface_images.each do |surface_image|
  #    p surface_image.original_zoom_level
  #  end
    surface_images.map(&:original_zoom_level).max
  end

  def zooms
    return unless tiled?
    (Dir.entries(tile_dir) - [".", ".."]).map{|e| e.to_i }
  end

  def maxzoom
    return unless tiled?
    zooms.max
  end

  def minzoom
    return unless tiled?
    zooms.min
  end

  def tile_image_path(z,x,y, opts = {})
    extension = opts[:extension] || 'png'
    File.join(tile_dir,z.to_s,"#{x}_#{y}.#{extension}")
  end

  def clean_tiles(options = {})
    if Dir.exists?(tile_dir)
      line = Terrapin::CommandLine.new("rm", "-r :tile_dir", logger: logger)
      line.run(tile_dir: tile_dir)
    end
  end


  def make_tiles_cmd(options = {})
    maxzoom = options[:maxzoom] || self.max_zoom_level || self.original_zoom_level
    transparent = options.has_key?(:transparent) ? options[:transparent] : true
    transparent_color = options.has_key?(:transparent_color) ? options[:transparent_color] : false
    multi  = options.has_key?(:multi) ? options[:multi] : 4
    args = []
    surface_images.reverse.each_with_index do |surface_image, index|
      if surface_image.wall
        next
      end
      next if surface_image.image.fits_file?
      image_path = surface_image.image_path
      next unless File.exist?(image_path)
      args << image_path
      args << surface_image.corners_on_world_str("%.2f")
    end
    return if args.empty?
    cmd = args.join(" ")
    ce = surface.center
    if ce && ce.size == 2
      center_str = sprintf("[%.2f,%.2f]", ce[0], ce[1])
      length_str = sprintf("%.2f", surface.length)
      cmd += " #{length_str} #{center_str} -o #{tile_dir} -z #{maxzoom}"
    end
    cmd += " -t" if transparent
    cmd += " #{transparent_color}" if transparent_color
    cmd += " --multi #{multi}" if multi
    cmd
    line = Terrapin::CommandLine.new("make_tiles", cmd, logger: logger)
  end

  def make_tiles(options = {})
    line = make_tiles_cmd(options)
    line.run
  end
  
  def merge_tiles
    clean_tiles
    surface_images.reverse.each do |surface_image|
      next if surface_image.wall
      surface_image.merge_tiles
    end
  end

  def transform(affine_matrix = "[[1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0]]")
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
      end
    end
  end

end
