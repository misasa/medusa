class Surface < ActiveRecord::Base
  include HasRecordProperty
  has_many :surface_images, :dependent => :destroy
  has_many :images, through: :surface_images	
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true

  def first_image
  	surface_image = surface_images.order('position ASC').first
  	surface_image.image if surface_image
  end
end
