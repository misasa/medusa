class PhysicalForm < ApplicationRecord
  has_many :specimens

  validates :name, presence: true, length: {maximum: 255}
end
