class SurfaceLayer < ActiveRecord::Base
  belongs_to :surface
  has_many :surface_images, :dependent => :nullify, :order => ("position DESC")
  has_many :images, through: :surface_images
  acts_as_list :scope => :surface_id, column: :priority

  validates :surface_id, presence: true
  validates :surface, existence: true, allow_nil: true
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :surface_id }
  validates :opacity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :priority, presence: true, numericality: { greater_than_or_equal_to: 1 }, uniqueness: { scope: :surface_id }

  def self.max_priority
    all.maximum(:priority) || 0
  end

  def bounds
    return Array.new(4) { 0 } if surface.globe? || images.blank?
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
 
  def tile_dir
    File.join(surface.map_dir, "layeres","#{id}")
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

  def merge_images
    clean_tiles
    surface_images.to_a[0..2].reverse.each do |surface_image|
      puts "#{surface_image.image_id}"
      0.upto(surface_image.original_zoom_level) do |zoom|
        target_dir = File.join(tile_dir, "#{zoom}")
        unless Dir.exists?(target_dir)
          line = Terrapin::CommandLine.new("mkdir", "-p :dir", logger: logger)
          line.run(dir: File.join(target_dir))
        end  
        surface_image.tiles_each(zoom) do |x, y|
          src_path = surface_image.tile_image_path(zoom,x,y)
          dest_path = tile_image_path(zoom,x,y)
          if File.exists?(dest_path)
            line = Terrapin::CommandLine.new("composite", "-compose over :dest :src :dest")
            line.run(src: src_path, dest: dest_path)
          else
            line = Terrapin::CommandLine.new("cp", ":src :dest", logger: logger)
            line.run(src: src_path, dest: dest_path)
          end
        end
      end
    end
  end

end
