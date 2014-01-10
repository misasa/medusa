class Spot < ActiveRecord::Base
  has_one :record_property, as: :datum
  belongs_to :attachment_file

  validates :attachment_file, existence: true
end
