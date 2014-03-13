class Place < ActiveRecord::Base
  include HasRecordProperty
  include OutputPdf
  include OutputCsv

  TEMPLATE_HEADER = "name,latitude(decimal degree),longitude(decimal degree),elevation(m),description\n"

  acts_as_mappable

  has_many :stones
  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings, as: :referable
  has_many :bibs, through: :referrings

  def self.import_csv(file)
    if file.content_type == "text/csv"
      table = CSV.parse(file.read, headers: [:name, :latitude, :longitude, :elevation, :description])
      table.delete(0)
      ActiveRecord::Base.transaction do
        table.each do |row|
          place = new(row.to_hash)
          place.save!
        end
      end
    end
  end

end
