class SpecimenQuantity < ActiveRecord::Base
  include Quantity

  belongs_to :specimen
  belongs_to :divide

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
end
