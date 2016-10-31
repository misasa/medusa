class RecordProperty < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :datum, polymorphic: true
  has_one :global_qr
  delegate :ghost?, to: :datum, allow_nil: true

  before_save :generate_global_id, if: "global_id.blank?"
  before_save :adjust_published_at
  before_save :adjust_disposed_at
  before_save :adjust_lost_at

  validates :user, existence: true
  validates :group, existence: true, allow_nil: true

  alias_attribute :owner_readable?, :owner_readable
  alias_attribute :owner_writable?, :owner_writable
  alias_attribute :group_readable?, :group_readable
  alias_attribute :group_writable?, :group_writable
  alias_attribute :guest_readable?, :guest_readable
  alias_attribute :guest_writable?, :guest_writable

  scope :readables, ->(user) {
    return all if user.admin?
    where_clauses = owner_readables_where_clauses(user)
    where_clauses = where_clauses.or(group_readables_where_clauses(user))
    where_clauses = where_clauses.or(guest_readables_where_clauses)
    includes(:user, :group).where(where_clauses).references(:user)
  }

  def datum_attributes
    return unless datum

#    h = datum.attributes
#    h.merge!("global_id" => datum.global_id) if datum.respond_to?(:global_id)
#    h.merge!("thumbnail_path" => datum.thumbnail_path) if datum.respond_to?(:thumbnail_path)
    datum.decorate.as_json
  end

  def writable?(user)
    user.admin? || (owner?(user) && owner_writable?) || (group?(user) && group_writable?) || guest_writable?
  end

  def readable?(user)
    user.admin? || (owner?(user) && owner_readable?) || (group?(user) && group_readable?) || guest_readable?
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

  def dispose
    update_attributes(disposed: true)
  end

  def restore
    update_attributes(disposed: false)
  end

  def lose
    update_attributes(lost: true)
  end

  def found
    update_attributes(lost: false)
  end

  def adjust_published_at
    if published
      self.published_at = Time.now if published_at.blank?
    else
      self.published_at = nil
    end
  end

  def adjust_disposed_at
    if disposed
      self.disposed_at = Time.now if disposed_at.blank?
    else
      self.disposed_at = nil
    end
  end

  def adjust_lost_at
    if lost
      self.lost_at = Time.now if lost_at.blank?
    else
      self.lost_at = nil
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
