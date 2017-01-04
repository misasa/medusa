class Box < ActiveRecord::Base
  include HasRecordProperty
  include HasViewSpot
  include OutputPdf
  include OutputCsv
  include HasAttachmentFile
  include HasRecursive
  include HasPath
  include HasQuantity

  self.recursive_path_update = true

  acts_as_taggable
  #with_recursive

  has_many :users
  has_many :specimens, -> { order(:name) }, dependent: :restrict_with_error
  has_many :boxes, class_name: "Box", foreign_key: :parent_id, dependent: :restrict_with_error
  has_many :children, -> { order(:name) }, class_name: "Box", foreign_key: :parent_id, dependent: :restrict_with_error
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings
  belongs_to :parent, class_name: "Box", foreign_key: :parent_id
  belongs_to :box_type

  delegate :name, to: :box_type, prefix: true, allow_nil: true

  validates :box_type, existence: true, allow_nil: true
  validates :parent_id, existence: true, allow_nil: true
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :parent_id }
  validate :parent_id_cannot_self_children, if: ->(box) { box.parent_id }
  validates :quantity, presence: { if: -> { quantity_unit.present? } }
  validates :quantity, numericality: true, allow_blank: true
  validates :quantity_unit, presence: { if: -> { quantity.present? } }
  validate :quantity_unit_exists

  after_save :reset_path

  def as_json(options = {})
    super({ methods: [:global_id, :box_type_name, :primary_file_thumbnail_path] }.merge(options))
  end

  def quantity_with_unit
    return unless quantity
    "#{quantity} #{quantity_unit}"
  end

  def quantity_with_unit=(string)
    vals = string.split(/\s/)
    self.quantity = vals[0]
    self.quantity_unit = vals[1] if vals.size > 1
  end

  def analyses
    analyses = []
    specimens.each do |specimen| 
      (analyses = analyses + specimen.analyses) unless specimen.analyses.empty?
    end
    analyses
  end

  def related_spots
    ancestors.map{|box| box.spot_links }.flatten
  end

  def total_decimal_quantity
    descendants.inject(specimens_decimal_quantity) do |sum, box|
      (box.disposal_or_loss? ? sum : sum + box.box_decimal_quantity) + box.specimens_decimal_quantity
    end
  end

  def specimens_decimal_quantity
    specimens.inject(0.to_d) do |sum, specimen|
      specimen.disposal_or_loss? ? sum : sum + specimen.decimal_quantity
    end
  end

  def box_decimal_quantity
    # 重量が負数の場合、総量計算上は重さ0とする
    decimal_quantity >= 0 ? decimal_quantity : 0.to_d
  end

  private

  def parent_id_cannot_self_children
    invalid_ids = descendants.map(&:id).unshift(self.id)
    if invalid_ids.include?(self.parent_id)
      errors.add(:parent_id, " make loop.")
    end
  end

  def reset_path
    self.path = ""
    self.update_column(:path, "/#{self.ancestors.map(&:name).join('/')}") if self.parent
  end

  def path_changed?
    parent_id_changed?
  end

  def path_ids
    ancestors.map(&:id)
  end

end
