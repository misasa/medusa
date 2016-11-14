class Divide < ActiveRecord::Base
  belongs_to :before_specimen_quantity, class_name: "SpecimenQuantity"
  has_one :before_specimen, through: :before_specimen_quantity, source: :specimen
  has_many :specimen_quantities

  default_scope -> { order(:updated_at) }

  scope :specimen_id_is, -> (id) { includes(:before_specimen_quantity).where(specimen_quantities: { specimen_id: id }) }

  def chart_updated_at
    (updated_at.to_i + 9.hours) * 1000
  end

  def updated_at_str
    updated_at.strftime("%Y/%m/%d %H:%M:%S")
  end
end
