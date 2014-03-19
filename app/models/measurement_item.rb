class MeasurementItem < ActiveRecord::Base
  has_many :chemistries
  has_many :category_measurement_items
  has_many :measurement_categories, through: :category_measurement_items
  belongs_to :unit

  validates :nickname, presence: true, length: {maximum: 255}
  validates :unit, existence: true, allow_nil: true
  
  def display_name
    display_in_html.blank? ? nickname : display_in_html
  end

  def tex_name
    display_in_tex.blank? ? nickname : display_in_tex
  end
end
