class Analysis < ActiveRecord::Base
  include HasRecordProperty

  has_many :chemistries
  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings, as: :referable
  has_many :bibs, through: :referrings
  belongs_to :stone
  belongs_to :device
  belongs_to :technique

  validates :stone, existence: true, allow_nil: true
  validates :device, existence: true, allow_nil: true
  validates :technique, existence: true, allow_nil: true
  validates :name, presence: true, length: { maximum: 255 }

  MeasurementCategory.all.each do |mc|
    comma mc.name.to_sym do
      name "session"
      name "instrument"
      name "technique"
      name "description"
      name "analyst"
      name "analysed_at"
      name "sample_uid"
      mc.export_headers.map { |header| name header }
    end
  end

  def chemistry_summary(length=100)
    display_names = chemistries.map { |ch| ch.display_name if ch.measurement_item }.compact
    display_names.join(", ").truncate(length)
  end

  def stone_global_id
    stone.try!(:global_id)
  end

  def stone_global_id=(global_id)
    self.stone = Stone.joins(:record_property).where(record_properties: {global_id: global_id}).first
  end

end

