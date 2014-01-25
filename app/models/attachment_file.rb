class AttachmentFile < ActiveRecord::Base
  include HasRecordProperty

  has_many :spots
  has_many :attachings
end
