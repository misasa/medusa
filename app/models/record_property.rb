class RecordProperty < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :datum, polymorphic: true
  has_one :global_qr

  before_save :generate_global_id, if: "global_id.blank?"
  before_save :adjust_published_at

  validates :user, existence: true
  validates :group, existence: true, allow_nil: true

  alias_attribute :owner_readable?, :owner_readable
  alias_attribute :owner_writable?, :owner_writable
  alias_attribute :group_readable?, :group_readable
  alias_attribute :group_writable?, :group_writable
  alias_attribute :guest_readable?, :guest_readable
  alias_attribute :guest_writable?, :guest_writable

  scope :readables, ->(user) {
    where_clauses = owner_readables_where_clauses(user)
    where_clauses = where_clauses.or(group_readables_where_clauses(user))
    where_clauses = where_clauses.or(guest_readables_where_clauses)
    includes(:user, :group).where(where_clauses)
  }

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

  def adjust_published_at
    if published
      self.published_at = Time.now if published_at.blank?
    else
      self.published_at = nil
    end
  end

  private

  def self.owner_readables_where_clauses(user)
    record_properties = self.arel_table
    record_properties[:owner_readable].eq(true).and(record_properties[:user_id].eq(user.id))
  end

  def self.group_readables_where_clauses(user)
    record_properties = self.arel_table
    group_members = GroupMember.arel_table
    record_properties[:group_readable].eq(true).and(GroupMember.where(group_members[:user_id].eq(user.id).and(group_members[:group_id].eq(record_properties[:group_id]))).exists)
  end

  def self.guest_readables_where_clauses
    self.arel_table[:guest_readable].eq(true)
  end
end
