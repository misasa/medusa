class GroupMember < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :group, existence: true
  validates :user, existence: true
end
