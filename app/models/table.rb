class Table < ActiveRecord::Base
  include HasRecordProperty

  has_many :table_stones, -> { order :position }, dependent: :destroy
  has_many :stones, through: :table_stones
  has_many :analyses, through: :stones
  has_many :chemistries, through: :stones
  has_many :measurement_items, through: :measurement_category
  belongs_to :bib
  belongs_to :measurement_category

  def each(display: :nickname, &block)
    measurement_items.each do |measurement_item|
      chemistries_hash[measurement_item.id].each do |methods, chemistries|
        yield item_label(measurement_item, methods, display: display), chemistries
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

  def item_label(measurement_item, methods, display: :nickname)
    str = "#{item_name(measurement_item, display: display)}"
    sign = method_sign(*methods)
    str += "(#{sign})" if sign.present?
    str
  end

  def item_name(measurement_item, display: :nickname)
    case display
    when :html
      measurement_item.display_in_html
    when :tex
      measurement_item.display_in_tex
    else
      measurement_item.nickname
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
    return methods_hash[[technique.id, device.id]][:sign] if methods_hash[[technique.id, device.id]].present?
    sign = methods_hash[[technique.id, device.id]][:sign] = assign_sign
    methods_hash[[technique.id, device.id]][:description] = "#{technique.try!(:name)} " if technique.present?
    methods_hash[[technique.id, device.id]][:description] += "on #{device.name}" if device.present?
    sign
  end

end
