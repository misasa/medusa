class Specimen < ActiveRecord::Base
  include HasRecordProperty
  include HasViewSpot
  include OutputPdf
  include OutputCsv
  include HasAttachmentFile
  include HasRecursive
  include HasPath
  include HasQuantity

  attr_accessor :divide_flg
  attr_accessor :comment

  acts_as_taggable
 #with_recursive

  #試料状態
  module Status
    # 正常
    NORMAL = 0
    # 未定量
    UNDETERMINED_QUANTITY = 1
    # 消失
    DISAPPEARANCE = 2
    # 廃棄
    DISPOSAL = 3
    # 紛失
    LOSS = 4
  end

  before_save :build_specimen_quantity,
    if: -> (s) { !s.divide_flg && (s.quantity_changed? || s.quantity_unit_was.presence != s.quantity_unit.presence) }

  has_many :analyses, before_remove: :delete_table_analysis
  has_many :children, -> { order(:name) }, class_name: "Specimen", foreign_key: :parent_id, dependent: :nullify
  has_many :specimens, class_name: "Specimen", foreign_key: :parent_id, dependent: :nullify  
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings
  has_many :chemistries, through: :analyses
  has_many :specimen_custom_attributes, dependent: :destroy
  has_many :custom_attributes, through: :specimen_custom_attributes
  has_many :specimen_quantities
  belongs_to :parent, class_name: "Specimen", foreign_key: :parent_id
  belongs_to :box
  belongs_to :place
  belongs_to :classification
  belongs_to :physical_form

  accepts_nested_attributes_for :specimen_quantities
  accepts_nested_attributes_for :specimen_custom_attributes
  accepts_nested_attributes_for :children

  validates :box, existence: true, allow_nil: true
  validates :place, existence: true, allow_nil: true
  validates :classification, existence: true, allow_nil: true
  validates :physical_form, existence: true, allow_nil: true
  #validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :box_id }
  validates :name, presence: true, length: { maximum: 255 }
  validate :parent_id_cannot_self_children, if: ->(specimen) { specimen.parent_id }
  validates :igsn, uniqueness: true, length: { maximum: 9 }, allow_nil: true, allow_blank: true
  validates :age_min, numericality: true, allow_nil: true
  validates :age_max, numericality: true, allow_nil: true
  validates :age_unit, presence: true, if: -> { age_min.present? || age_max.present? }
  validates :age_unit, length: { maximum: 255 }
  validates :quantity, presence: { if: -> { quantity_unit.present? } }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :quantity_unit, presence: { if: -> { quantity.present? } }
  validate :quantity_unit_exists
  validates :size, length: { maximum: 255 }
  validates :size_unit, length: { maximum: 255 }
  validates :collector, length: { maximum: 255 }
  validates :collector_detail, length: { maximum: 255 }
  validates :collection_date_precision, length: { maximum: 255 }
  validate :status_is_nomal, on: :divide

  def status
    return unless record_property
    if record_property.disposed
      Status::DISPOSAL
    elsif record_property.lost
      Status::LOSS
    elsif quantity.blank? || decimal_quantity < 0
      Status::UNDETERMINED_QUANTITY
    elsif decimal_quantity.zero?
      Status::DISAPPEARANCE
    else
      Status::NORMAL
    end
  end

  def set_specimen_custom_attributes
    ids = specimen_custom_attributes.pluck('DISTINCT custom_attribute_id')
    if ids.size == CustomAttribute.count
      specimen_custom_attributes.joins(:custom_attribute).includes(:custom_attribute).order("custom_attributes.name")
    else
      (CustomAttribute.pluck(:id) - ids).each do |custom_attribute_id|
        specimen_custom_attributes.build(custom_attribute_id: custom_attribute_id)
      end
      specimen_custom_attributes.sort_by {|sca| sca.custom_attribute.name }
    end
  end

  def full_analyses
    Analysis.where(specimen_id: self_and_descendants)
  end

  def ghost?
    quantity && quantity <= 0 || [Status::DISAPPEARANCE, Status::DISPOSAL, Status::LOSS].include?(status)
  end

  def related_spots
    sps = ancestors.map{|box| box.spot_links }.flatten || []
    sps.concat(box.related_spots) if box
    sps
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

  # def to_pml
  #   [self].to_pml
  # end

  def age_mean
    return unless ( age_min && age_max )
    (age_min + age_max) / 2.0
  end

  def age_error
    return unless ( age_min && age_max )
    (age_max - age_min) / 2.0
  end

  def age_in_text(opts = {})
    unit = opts[:unit] || self.age_unit
    scale = opts[:scale] || 0
    text = nil
    if age_mean && age_error
      #text = "#{age_mean}(#{age_error(opts)})"
      text = Alchemist.measure(self.age_mean, self.age_unit.to_sym).to(unit.to_sym).value.round(scale).to_s
      text += " (" + Alchemist.measure(self.age_error, self.age_unit.to_sym).to(unit.to_sym).value.round(scale).to_s + ")"
    elsif age_min
      text = ">" + Alchemist.measure(self.age_min, self.age_unit.to_sym).to(unit.to_sym).value.round(scale).to_s
    elsif age_max
      text = "<" + Alchemist.measure(self.age_max, self.age_unit.to_sym).to(unit.to_sym).value.round(scale).to_s      
    end
    text += " #{unit}" if text && opts[:with_unit]
    return text
  end

  def relatives_for_tree
    list = [self].concat(children)
    #list = [root].concat(root.children)
    ans = ancestors
    depth = ans.size
    if depth > 0
      list.concat(siblings)
      list.concat(ans)
      ans.each do |an|
        list.concat(an.siblings)
      end
    # elsif depth > 1
    #   list.concat(ans[1].descendants)
    end
    list.uniq!
    families.select{|e| list.include?(e) }    
  end

  def quantity_history
    return @quantity_history if @quantity_history
    divides = Divide.includes(:specimen_quantities).specimen_id_is(self_and_descendants.map(&:id))
    total_hash = {}
    h = Hash.new {|h, k| h[k] = Array.new }
    @quantity_history = divides.each_with_object(h) do |divide, hash|
      divide.specimen_quantities.each do |specimen_quantity|
        hash[specimen_quantity.specimen_id] << specimen_quantity.point
        total_hash[specimen_quantity.specimen_id] = specimen_quantity.decimal_quantity
      end
      total_val = total_hash.values.compact.sum
      hash[0] << SpecimenQuantity.point(divide, total_val.to_f, Quantity.string_quantity(total_val, "g"))
    end
    last_divide = divides.last
    @quantity_history.each do |key, quantity_line|
      if quantity_line.last[:id] != last_divide.id
        quantity_line << SpecimenQuantity.point(last_divide, quantity_line.last[:y], quantity_line.last[:quantity_str])
      end
    end
    @quantity_history
  end

  def divided_parent_quantity
    children_decimal_quantity = new_children.inject(0.to_d) do |sum, specimen|
      sum + specimen.decimal_quantity
    end
    decimal_quantity_was - children_decimal_quantity
  end

  def divided_loss
    divided_parent_quantity - decimal_quantity
  end

  def divide_save
    self.divide_flg = true
    ActiveRecord::Base.transaction do
      divide = build_divide
      divide.save!
      build_specimen_quantity(divide)
      new_children.each do |child|
        child.divide_flg = true
        child.build_specimen_quantity(divide)
      end
      save!
    end
  end

  def build_specimen_quantity(divide = build_divide)
    specimen_quantity = specimen_quantities.build
    specimen_quantity.quantity = quantity
    specimen_quantity.quantity_unit = quantity_unit
    specimen_quantity.divide = divide
    specimen_quantity
  end

  private

  def new_children
    children.select(&:new_record?).to_a
  end

  def build_divide
    divide = Divide.new
    divide.before_specimen_quantity = specimen_quantities.last
    divide.divide_flg = divide_flg || false
    divide.log = build_log
    divide
  end

  def build_log
    if divide_flg
      comment
    elsif string_quantity_was.blank?
      "Quantity of #{name} was set to #{string_quantity}"
    elsif string_quantity.blank?
      "Quantity of #{name} was deleted"
    else
      "Quantity of #{name} was changed from #{string_quantity_was} to #{string_quantity}"
    end
  end

  def parent_id_cannot_self_children
    invalid_ids = descendants.map(&:id).unshift(self.id)
    if invalid_ids.include?(self.parent_id)
      errors.add(:parent_id, " make loop.")
    end
  end

  def status_is_nomal
    unless status == Status::NORMAL
      errors.add(:status, " is not normal")
    end
  end

  def path_changed?
    box_id_changed?
  end

  def path_ids
    box.present? ? box.ancestors + [box.id] : []
  end

  def delete_table_analysis(analysis)
    TableAnalysis.delete_all(analysis_id: analysis.id, specimen_id: self.id)
  end
end
