class Analysis < ActiveRecord::Base
  include HasRecordProperty

  PERMIT_IMPORT_TYPES = ["text/plain", "text/csv", "application/csv"]

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
      name "name"
      name "device_name"
      name "technique_name"
      name "description"
      name "operator"
      name "stone_global_id"
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

  def device_name=(name)
    self.device_id = Device.find_by(name: name).try(:id)
  end

  def technique_name=(name)
    self.technique_id = Technique.find_by(name: name).try(:id)
  end

  def self.import_csv(file)
    if file && PERMIT_IMPORT_TYPES.include?(file.content_type)
      objects = build_objects_from_csv(file)
      if objects.all?(&:valid?)
        objects.map {|obj| obj.save}
      else
        false
      end
    end
  end

  def self.build_objects_from_csv(file)
    csv = CSV.parse(file.read, row_sep: :auto)
    methods = csv.shift.compact.map {|column| column.gsub(/ /,'_')}
    csv.inject([]) do |objects, row|
      objects + [set_object(methods, row)] if row.any?(&:present?)
    end
  end

  def self.set_object(methods, data_array)
    data_array.each { |data| data.strip! unless data.blank? }
    pkey_value = methods.index("id") ? data_array[methods.index("id")] : nil
    object = Analysis.find_or_initialize_by(id: pkey_value)
    object.attributes = Hash[methods.zip(data_array)]
    object
  end

  def method_missing(method_name, *arguments)
    if (method_name.to_s =~ /^(.+?)(_error)?(?:_in_(.+))?(=)?$/) && MeasurementItem.exists?(nickname: $1)
      if $4.present?
        if $2.present?
          set_uncertainty($1, arguments[0])
        else
          set_chemistry($1, $3, arguments[0])
        end
      elsif $2.blank?
        get_chemistry_value($1, $3)
      else
        super
      end
    else
      super
    end
  end

  def set_chemistry(measurement_item_name, unit_name, data)
    measurement_item = MeasurementItem.find_by(nickname: measurement_item_name)
    value = data
    value.strip! if value.is_a? String
    if value
      unless unit_name
        if measurement_item.unit
          unit_name = measurement_item.unit.name
        else
          unit_name = "parts"
        end
      end
      unit = Unit.find_by(name: unit_name)
      chemistries.build(measurement_item_id: measurement_item.id, value: value, unit_id: unit.try(:id))
    end
  end

  def set_uncertainty(measurement_item_name, data)
    chemistry = associate_chemistry_by_item_nickname(measurement_item_name)
    if chemistry
      uncertainty = data
      uncertainty.strip! if uncertainty.is_a? String
      chemistry.uncertainty = uncertainty
    end
  end

  # TODO chemistry.value を単位変換して返す
  def get_chemistry_value(measurement_item_name, unit_name)
    chemistry = associate_chemistry_by_item_nickname(measurement_item_name)
    if chemistry
      chemistry.value
    end
  end

  def associate_chemistry_by_item_nickname(nickname)
    chemistries.joins(:measurement_item).merge(MeasurementItem.where(nickname: nickname)).first
  end

  def self.to_castemls(analyses)
    xml = ::Builder::XmlMarkup.new(indent: 2)
    xml.instruct!
    xml.acquisitions do
      analyses.each do |analysis|
        analysis.to_pml(xml)
      end
    end
  end

  def to_pml(xml)
    xml.acquisition do
      xml.global_id(global_id)
      xml.name(name)
      xml.device(device.try!(:name))
      xml.technique(technique.try!(:name))
      xml.operator(operator)
      xml.sample_global_id(stone.try!(:global_id))
      xml.sample_name(stone.try!(:name))
      xml.description(description)
      spot = get_spot
      if spot
        xml.spot do
          xml.global_id(spot.global_id)
          xml.attachment_file_global_id(spot.attachment_file.try!(:global_id))
          xml.x_image(spot.spot_x_from_center)
          xml.y_image(spot.spot_y_from_center)
        end
      end
      unless chemistries.empty?
        xml.chemistries do
          chemistries.each do |chemistry|
            xml.analysis do
              xml.nickname(chemistry.measurement_item.try!(:nickname))
              xml.value(chemistry.value)
              xml.unit(chemistry.unit.try!(:text))
              xml.uncertainty(chemistry.uncertainty)
              xml.label(chemistry.label)
              xml.info(chemistry.info)
            end
          end
        end
      end
    end
  end

  def get_spot
    spots =  Spot.find_all_by_target_uid(global_id)
    return if spots.empty?
    spots[0]
  end 

end
