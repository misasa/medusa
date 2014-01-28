module HasRecordProperty
  extend ActiveSupport::Concern

  included do
    has_one :record_property, as: :datum
    delegate :global_id, :writable?, :readable?, to: :record_property

    scope :readables, ->(user) {
      where_clauses = owner_readables_where_clauses(user)
      where_clauses = where_clauses.or(group_readables_where_clauses(user))
      where_clauses = where_clauses.or(guest_readables_where_clauses)
      includes(:record_property).where(where_clauses)
    }
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
