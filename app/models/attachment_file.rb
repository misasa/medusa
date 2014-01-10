class AttachmentFile < ActiveRecord::Base
  has_one :record_property, as: :datum
  has_many :spots
  has_many :attachings
end
