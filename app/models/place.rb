class Place < ActiveRecord::Base
  include HasRecordProperty
  include OutputPdf
  include OutputCsv

  TEMPLATE_HEADER = "name,latitude(decimal degree),longitude(decimal degree),elevation(m),description\n"
  PERMIT_IMPORT_TYPES = ["text/plain", "text/csv", "application/csv"]

  acts_as_mappable

  has_many :stones
  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings, as: :referable
  has_many :bibs, through: :referrings

  validates :name, presence: true, length: { maximum: 255 }

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

end
