# -*- coding: utf-8 -*-
class Box < ApplicationRecord
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

  validates :box_type, presence: { message: :required, if: -> { box_type_id.present? } }
  validates :parent_id, presence: { message: :required, if: -> { parent_id.present? } }
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


  def ghost?
    [Status::DISAPPEARANCE, Status::DISPOSAL, Status::LOSS].include?(status)
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

  def recursive_inventory(checked_at)
    specimens.where(fixed_in_box: true).each { |specimen| specimen.paths.current.first.update(checked_at: checked_at) if specimen.paths.current.first }
    boxes.where(fixed_in_box: true).each { |box| box.paths.current.first.update(checked_at: checked_at) if box.paths.current.first }
  end

  def recursive_lose
    specimens.where(fixed_in_box: true).each(&:lose)
    boxes.where(fixed_in_box: true).each(&:lose)
  end

  def recursive_found
    specimens.where(fixed_in_box: true).each(&:found)
    boxes.where(fixed_in_box: true).each(&:found)
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
    saved_change_to_parent_id?
  end

  def path_ids
    ancestors.map(&:id)
  end

end
