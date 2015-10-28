class Table < ActiveRecord::Base
  include HasRecordProperty

  has_many :table_stones, -> { order :position }, dependent: :destroy
  has_many :stones, through: :table_stones
  has_many :analyses, through: :stones
  has_many :chemistries, through: :stones
  has_many :category_measurement_items, through: :measurement_category
  has_many :measurement_items, through: :measurement_category
  belongs_to :bib
  belongs_to :measurement_category

  ChemicalSpecies = Struct.new(:category_measurement_item, :sign) do

    delegate :unit, :scale, to: :category_measurement_item

    def caption(type = :nickname)
      str = name(type)
      str += "(#{sign})" if sign.present?
      str
    end

    def name(type = :nickname)
      case type
      when :html
        category_measurement_item.measurement_item.display_in_html
      when :tex
        category_measurement_item.measurement_item.display_in_tex
      else
        category_measurement_item.measurement_item.nickname
      end
    end

  end

  def each(display: :nickname, &block)
    category_measurement_items.includes(:measurement_item).each do |category_measurement_item|
      chemistries_hash[category_measurement_item.measurement_item_id].each do |methods, chemistries|
        chemical_species = ChemicalSpecies.new(category_measurement_item, method_sign(*methods))
        yield chemical_species, chemistries
      end
    end
  end

  def method_descriptions
    methods_hash.values.each_with_object({}) { |value, hash| hash[value[:sign]] = value[:description] }
  end

  # private

  def chemistries_hash
    init_hash = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
    @chemistries_hash ||= chemistries.includes(analysis: [:technique, :device]).each_with_object(init_hash) do |chemistry, hash|
      hash[chemistry.measurement_item_id][[chemistry.analysis.technique, chemistry.analysis.device]][chemistry.analysis.stone_id] = chemistry
    end
  end

  def assign_sign
    @assign_sign ||= "a"
    sign = @assign_sign.dup
    @assign_sign.succ!
    sign
  end

  def methods_hash
    @methods_hash ||= Hash.new { |h, k| h[k] = {} }
  end

  def method_sign(technique, device)
    return if technique.blank? && device.blank?
    technique_id = technique.try!(:id)
    device_id = device.try!(:id)
    return methods_hash[[technique_id, device_id]][:sign] if methods_hash[[technique_id, device_id]].present?
    sign = methods_hash[[technique_id, device_id]][:sign] = assign_sign
    methods_hash[[technique_id, device_id]][:description] = technique.present? ? "#{technique.try!(:name)} " : ""
    methods_hash[[technique_id, device_id]][:description] += "on #{device.name}" if device.present?
    sign
  end

end
