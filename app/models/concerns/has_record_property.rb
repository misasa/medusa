module HasRecordProperty
  extend ActiveSupport::Concern

  included do
    has_one :record_property, as: :datum, dependent: :destroy
    has_one :user, through: :record_property
    has_one :group, through: :record_property
    accepts_nested_attributes_for :record_property
    delegate :global_id, :published_at, :readable?, to: :record_property
    delegate :user_id, :group_id, :published, to: :record_property, allow_nil: true

    after_create :generate_record_property
    after_save :update_record_property

    scope :readables, ->(user) { includes(:record_property).joins(:record_property).merge(RecordProperty.readables(user)) }
  end

  def to_json(options = {})
    #self.to_json(:methods => :global_id)
    super({:methods => :global_id}.merge(options))
  end

  def to_xml(options = {})
    #self.to_json(:methods => :global_id)
    super({:methods => :global_id}.merge(options))
  end

  def user_id=(id)
    record_property && record_property.user_id = id
  end

  def group_id=(id)
    record_property && record_property.group_id = id
  end

  def published=(published)
    record_property && record_property.published = published
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
    record_property.name = self.try(:name)
    record_property.update_attribute(:updated_at, updated_at)
  end

end
