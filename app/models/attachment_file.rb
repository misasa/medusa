class AttachmentFile < ActiveRecord::Base
  include HasRecordProperty

  has_attached_file :data,
                    styles: { thumb: "160x120>", tiny: "50x50" },
                    path: ":rails_root/public/system/:class/:id/:filename_:style.:extension",
                    url: "/system/:class/:id/:filename_:style.:extension"

  has_many :spots
  has_many :attachings
  has_many :boxes, through: :attachings
  has_many :stones, through: :attachings
end
