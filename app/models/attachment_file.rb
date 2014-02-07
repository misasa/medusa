class AttachmentFile < ActiveRecord::Base
  include HasRecordProperty

  has_attached_file :data, path: ":rails_root/public/system/:class/:id/:filename", url: "/system/:class/:id/:filename"

  has_many :spots
  has_many :attachings
  has_many :attachable, through: :attachings
end
