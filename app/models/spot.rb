class Spot < ActiveRecord::Base
  include HasRecordProperty

  belongs_to :attachment_file

  validates :attachment_file, existence: true
end
