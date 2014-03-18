class MeasurementItem < ActiveRecord::Base
  has_many :chemistries
  has_many :category_measurement_items
  has_many :measurement_categories, through: :category_measurement_items
  belongs_to :unit

  validates :nickname, presence: true, length: {maximum: 255}
  
  def display_name
    display_in_html.blank? ? nickname : display_in_html
  end

end
