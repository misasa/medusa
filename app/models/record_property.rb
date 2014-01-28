class RecordProperty < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :datum, polymorphic: true
  has_one :global_qr

  validates :user, existence: true
  validates :group, existence: true

  alias_attribute :owner_readable?, :owner_readable
  alias_attribute :owner_writable?, :owner_writable
  alias_attribute :group_readable?, :group_readable
  alias_attribute :group_writable?, :group_writable
  alias_attribute :guest_readable?, :guest_readable
  alias_attribute :guest_writable?, :guest_writable

  def writable?(user)
    (owner?(user) && owner_writable?) || (group?(user) && group_writable?) || guest_writable?
  end

  def readable?(user)
    (owner?(user) && owner_readable?) || (group?(user) && group_readable?) || guest_readable?
  end

  def owner?(user)
    user_id == user.id
  end

  def group?(user)
    user.group_ids.include?(group_id)
  end
end
