class Table < ActiveRecord::Base

  has_many :table_stones, -> { order :position }, dependent: :destroy
  has_many :stones, through: :table_stones
  has_many :measurement_items, through: :measurement_category
  belongs_to :bib
  belongs_to :measurement_category

end
