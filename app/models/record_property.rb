class RecordProperty < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :datum, polymorphic: true
  has_one :global_qr

  # TODO 関連先の１つ Chemistry にはname属性がない
  delegate :name, :updated_at, to: :datum, allow_nil: true

  before_save :generate_global_id, if: "global_id.nil?"

  validates :user, existence: true
  validates :group, existence: true, allow_nil: true

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
  
  def generate_global_id
    time = Time.now
    self.global_id =  time.strftime("%Y%m%d%H%M%S") + '-' + sprintf('%06d',time.usec)[-3..-1] + sprintf('%03d',rand(1000))
  end
end
