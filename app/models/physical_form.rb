class PhysicalForm < ActiveRecord::Base
  has_many :specimens

  validates :name, presence: true, length: {maximum: 255}
end
