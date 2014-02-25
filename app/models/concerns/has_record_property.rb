module HasRecordProperty
  extend ActiveSupport::Concern

  included do
    has_one :record_property, as: :datum, dependent: :destroy
    has_one :user, through: :record_property
    has_one :group, through: :record_property
    accepts_nested_attributes_for :record_property
    delegate :global_id, :published, :published_at, :readable?, to: :record_property

    after_create :generate_record_property
    after_save :update_record_property

    scope :readables, ->(user) {
      where_clauses = owner_readables_where_clauses(user)
      where_clauses = where_clauses.or(group_readables_where_clauses(user))
      where_clauses = where_clauses.or(guest_readables_where_clauses)
      includes(:record_property, :user, :group).where(where_clauses)
    }
  end

  def writable?(user)
    new_record? || record_property.writable?(user)
  end

  def generate_record_property
    self.build_record_property unless self.record_property
    self.record_property.user_id = User.current.id unless User.current.nil?
    self.record_property.save
  end

  def update_record_property
    record_property.name = name if self.try(:name)
    record_property.update_attribute(:updated_at, updated_at)
  end

  module ClassMethods
    private

    def owner_readables_where_clauses(user)
      record_properties = RecordProperty.arel_table
      record_properties[:owner_readable].eq(true).and(record_properties[:user_id].eq(user.id))
    end

    def group_readables_where_clauses(user)
      record_properties = RecordProperty.arel_table
      group_members = GroupMember.arel_table
      record_properties[:group_readable].eq(true).and(GroupMember.where(group_members[:user_id].eq(user.id).and(group_members[:group_id].eq(record_properties[:group_id]))).exists)
    end

    def guest_readables_where_clauses
      record_properties = RecordProperty.arel_table
      record_properties[:guest_readable].eq(true)
    end
  end
end
