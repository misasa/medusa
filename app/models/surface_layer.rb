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

  def self.max_priority
    all.maximum(:priority) || 0
  end

  def bounds
    overlay_images = overlay_surface_images.map{|s_i| s_i.image }
    return Array.new(4) { 0 } if surface.globe? || overlay_images.blank?
    left,upper,right,bottom = overlay_images[0].bounds
    overlay_images.each do |image|
      next if image.bounds.blank?
      l,u,r,b = image.bounds
      left = l if l < left
      upper = u if u > upper
      right = r if r > right
      bottom = b if b < bottom
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

  def merge_tiles
    clean_tiles
    surface_images.reverse.each do |surface_image|
      next if surface_image.wall
      surface_image.merge_tiles
    end
  end

end
