class Device < ActiveRecord::Base
  has_many :analyses

  validates :name, presence: true, length: { maximum: 255 }
end
