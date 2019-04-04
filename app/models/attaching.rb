class Attaching < ActiveRecord::Base
  belongs_to :attachment_file
  belongs_to :attachable, polymorphic: true, :touch => true
  acts_as_list scope: [:attachable_id , :attachable_type], column: :position

  validates :attachment_file, existence: true
  validates :attachment_file_id, uniqueness: { scope: [:attachable_id, :attachable_type] }
end
