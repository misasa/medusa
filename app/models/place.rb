class Place < ApplicationRecord
  include HasRecordProperty
  include OutputPdf
  include OutputCsv
  include HasAttachmentFile

  attr_accessor :skip_conversion

  TEMPLATE_HEADER = "name,latitude(decimal degree),longitude(decimal degree),elevation(m),description\n"
  PERMIT_IMPORT_TYPES = ["text/plain", "text/csv", "application/csv", "application/vnd.ms-excel"]

  acts_as_mappable

  has_many :specimens, -> { order(:name) }
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings

  validates :name, presence: true, length: { maximum: 255 }
  before_save :dms_to_degree, unless: :skip_conversion?


  def self.from_dms(deg, min = 0.0, sec = 0.0)
    return unless deg
    degree = deg.to_f
    degree += min.to_f/60.0 if min
    degree += sec.to_f/3600.0 if sec
    degree
  end

  def self.to_dms(deg_float)
    deg = deg_float.to_i
    res = (deg_float - deg) * 60
    min = res.to_i
    sec = (res - min) * 60
    {deg: deg, min: min, sec: sec.round(1)}
  end

  def self.to_text(dms)
    items = []
    items << dms[:direction] if dms[:direction]
    items << "#{dms[:deg]} degree" if dms[:deg]
    items << "#{dms[:min]} minute" if dms[:min]
    items << "#{sprintf('%.1f', dms[:sec])} second" if dms[:sec]
    items.join(" ")
  end

  def self.to_html(dms)
    items = []
    items << dms[:direction] if dms[:direction]
    items << "#{dms[:deg]}&deg;" if dms[:deg]
    items << "#{dms[:min]}&prime;" if dms[:min]
    items << "#{sprintf('%.1f', dms[:sec])}&Prime;" if dms[:sec]
    items.join("")
  end

  def self.import_csv(file)
    if file && PERMIT_IMPORT_TYPES.include?(file.content_type)
      table = CSV.parse(file.read, headers: [:name, :latitude, :longitude, :elevation, :description])
      ActiveRecord::Base.transaction do
        table.delete(0)
        table.each do |row|
          place = new(row.to_hash)
          place.save!
        end
      end
    end
  end

  def as_json(options = {})
    #super({:methods => [:global_id, :pmlame_ids]}.merge(options))
    super({:methods => [:global_id]}.merge(options))
  end

  def dms_value_to_f(dms_hash)
    return if dms_hash.nil?
    dms_hash.map { |k, v| k == :direction ? [k, v] : [k, v.to_f] }.to_h
  end

  def _latitude_dms
    return {} if latitude.blank?

    latitude_dms = self.class.to_dms(latitude.abs)
    latitude_dms[:direction] = latitude < 0 ? "S" : "N"
    latitude_dms
  end

  def latitude_dms
    @latitude_dms ||= _latitude_dms
  end

  def latitude_dms_changed?
    dms_value_to_f(@latitude_dms) != _latitude_dms
  end

  def _longitude_dms
    return {} if longitude.blank?

    longitude_dms = self.class.to_dms(longitude.abs)
    longitude_dms[:direction] = longitude < 0 ? "W" : "E"
    longitude_dms
  end

  def longitude_dms
    @longitude_dms ||= _longitude_dms
  end

  def longitude_dms_changed?
    dms_value_to_f(@longitude_dms) != _longitude_dms
  end

  def to_html
    return latitude_to_html + ", " + longitude_to_html if latitude && longitude
  end

  def latitude_to_html
    self.class.to_html(latitude_dms)
  end

  def longitude_to_html
    self.class.to_html(longitude_dms)
  end

  def latitude_in_text
    self.class.to_text(latitude_dms)
  end

  def longitude_in_text
    self.class.to_text(longitude_dms)
  end

  def analyses
    analyses = []
    specimens.each do |specimen|
      (analyses = analyses + specimen.analyses) unless specimen.analyses.empty?
    end
    analyses
  end

  def latitude_dms_direction
    latitude_dms[:direction]
  end

  def latitude_dms_deg
    latitude_dms[:deg]
  end

  def latitude_dms_min
    latitude_dms[:min]
  end

  def latitude_dms_sec
    latitude_dms[:sec]
  end

  def longitude_dms_direction
    longitude_dms[:direction]
  end

  def longitude_dms_deg
    longitude_dms[:deg]
  end

  def longitude_dms_min
    longitude_dms[:min]
  end

  def longitude_dms_sec
    longitude_dms[:sec]
  end

  def method_missing(method, *args, &block)
    case method.to_s
    when /latitude\_dms\_(.*)=/
      latitude_dms[$1.to_sym] = args[0]
    when /longitude\_dms\_(.*)=/
      longitude_dms[$1.to_sym] = args[0]
    else
      super
    end
  end

  def skip_conversion?
    skip_conversion
  end

  protected
  def dms_to_degree
    #unless self.latitude
    if latitude_dms_changed?
      if self.latitude_dms_deg
        degree = self.class.from_dms(self.latitude_dms_deg, self.latitude_dms_min, self.latitude_dms_sec)
        degree = -1.0 * degree if self.latitude_dms_direction == 'S' || self.latitude_dms_direction == 'south'
        self.latitude = degree
      end
    end
    #unless self.longitude
    if longitude_dms_changed?
      if self.longitude_dms_deg
        degree = self.class.from_dms(self.longitude_dms_deg, self.longitude_dms_min, self.longitude_dms_sec)
        degree = -1.0 * degree if self.longitude_dms_direction == 'W' || self.longitude_dms_direction == 'west'
        self.longitude = degree
      end
    end
  end

  private

  def _assign_attribute(k, v)
    super
  rescue ActiveModel::UnknownAttributeError
    case k.to_s
    when /latitude\_dms\_(.*)/
      latitude_dms[$1.to_sym] = v
    when /longitude\_dms\_(.*)/
      longitude_dms[$1.to_sym] = v
    else
      raise
    end
  end

end
