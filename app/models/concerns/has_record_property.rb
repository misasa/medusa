module HasRecordProperty
  extend ActiveSupport::Concern

  included do
    has_one :record_property, as: :datum
    delegate :global_id, :writable?, :readable?, to: :record_property
  end
end
