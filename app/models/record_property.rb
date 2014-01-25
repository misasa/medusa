class RecordProperty < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :datum, polymorphic: true
  has_one :global_qr

  validates :user, existence: true
  validates :group, existence: true

  WRITE = 0b100
  READ = 0b010

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

  def owner_writable?
    permitted_to_write?(permission_u)
  end

  def owner_readable?
    permitted_to_read?(permission_u)
  end

  def group_writable?
    permitted_to_write?(permission_g)
  end

  def group_readable?
    permitted_to_read?(permission_g)
  end

  def guest_writable?
    permitted_to_write?(permission_o)
  end

  def guest_readable?
    permitted_to_read?(permission_o)
  end

  private

  def permitted_to_write?(permission)
    permitted_to?(WRITE, permission)
  end

  def permitted_to_read?(permission)
    permitted_to?(READ, permission)
  end

  def permitted_to?(action, permission)
    !(action & permission).zero?
  end
end
