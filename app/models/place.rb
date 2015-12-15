class Place < ActiveRecord::Base
  include HasRecordProperty
  include OutputPdf
  include OutputCsv
  include HasAttachmentFile

  attr_accessor :latitude_direction, :latitude_deg, :latitude_min, :latitude_sec, :longitude_direction, :longitude_deg, :longitude_min, :longitude_sec
  TEMPLATE_HEADER = "name,latitude(decimal degree),longitude(decimal degree),elevation(m),description\n"
  PERMIT_IMPORT_TYPES = ["text/plain", "text/csv", "application/csv", "application/vnd.ms-excel"]

  acts_as_mappable

  has_many :specimens
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings

  validates :name, presence: true, length: { maximum: 255 }
  before_save :dms_to_degree


  def self.to_dms(deg_float)
    deg = deg_float.to_i
    res = (deg_float - deg) * 60
    min = res.to_i
    sec = (res - min) * 60
    {deg: deg, min: min, sec: sec}
  end

  def self.to_text(deg_float)
    dms = to_dms(deg_float)
    "#{dms[:deg]} deg. #{dms[:min]} min. #{dms[:sec]} sec."
  end

  def self.to_html(deg_float)
    dms = to_dms(deg_float)
    "#{dms[:deg]}&deg; #{dms[:min]}&prime; #{format('%.2f', dms[:sec])}&Prime;"
  end

  def latitude_to_html
    return "" if latitude.blank?
    degree = latitude
    direction = "N"
    if latitude < 0
      direction = "S"
      degree = -1 * latitude
    end
    #dms = self.class.to_dms(degree)
    html = self.class.to_html(degree)
    "#{direction} #{html}"
  end

  def longitude_to_html
    return "" if longitude.blank?
    degree = longitude
    direction = "E"
    if longitude < 0
      direction = "W"
      degree = -1 * longitude
    end
    #dms = self.class.to_dms(degree)
    html = self.class.to_html(degree)
    "#{direction} #{html}"
  end


  def self.from_dms(deg, min = 0.0, sec = 0.0)
    return unless deg
    degree = deg.to_f
    degree += min.to_f/60.0 if min
    degree += sec.to_f/3600.0 if sec
    degree
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

  # def latitude_direction
  #   @latitude_direction
  # end

  # def latitude_direction=(direction)
  #   @latitude_direction = direction
  # end

  def latitude_in_text
    return unless latitude
    degree = latitude
    direction = "N"
    if latitude < 0
      direction = "S"
      degree = -1 * latitude
    end
    text = self.class.to_text(degree)
    "#{direction} #{text}"
  end

  def longitude_in_text
    return unless longitude
    degree = longitude
    direction = "E"
    if longitude < 0
      direction = "W"
      degree = -1 * longitude
    end
    text = self.class.to_text(degree)
    "#{direction} #{text}"
  end

  def analyses
    analyses = []
    specimens.each do |specimen| 
      (analyses = analyses + specimen.analyses) unless specimen.analyses.empty?
    end
    analyses
  end

  protected
  def dms_to_degree
    unless self.latitude
      if self.latitude_deg
        degree = self.class.from_dms(self.latitude_deg, self.latitude_min,self.latitude_sec)
        degree = -1.0 * degree if self.latitude_direction == 'S' || self.latitude_direction == 'south'
        self.latitude = degree
      end
    end
    unless self.longitude
      if self.longitude_deg
        degree = self.class.from_dms(self.longitude_deg, self.longitude_min,self.longitude_sec)
        degree = -1.0 * degree if self.longitude_direction == 'W' || self.longitude_direction == 'west'
        self.longitude = degree
      end
    end


  end

end
