class Unit < ActiveRecord::Base
  has_many :chemistries
  has_many :measurement_items
  has_many :measurement_categories

  validates :name, presence: true, length: { maximum: 255 }
  validates :conversion, presence: true, numericality: { only_integer: true }
  validates :html, presence: true, length: { maximum: 10 }
  validates :text, presence: true, length: { maximum: 10 }
end
