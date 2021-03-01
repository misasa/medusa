class BoxType < ApplicationRecord
  has_many :boxes

  validates :name, presence: true, length: {maximum: 255}
end
