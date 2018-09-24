class SurfaceLayer < ActiveRecord::Base
  belongs_to :surface
  has_many :surface_images, :dependent => :nullify
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
end
