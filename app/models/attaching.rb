class Attaching < ActiveRecord::Base
  belongs_to :attachment_file
  belongs_to :attachable, polymorphic: true

  validates :attachment_file, existence: true
end
