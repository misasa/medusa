class GlobalQr < ApplicationRecord
  belongs_to :record_property

  validates :record_property, presence: true
end
