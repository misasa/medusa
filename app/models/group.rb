class Group < ActiveRecord::Base
  has_many :group_members
  has_many :users, through: :group_members
  has_many :record_properties
end
