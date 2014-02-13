class BoxType < ActiveRecord::Base
  has_many :boxes

  validates :name, presence: true, length: {maximum: 255}
end
