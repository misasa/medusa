class GlobalQr < ActiveRecord::Base
  belongs_to :record_property

  validates :record_property, existence: true
end
