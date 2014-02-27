class AttachmentFile < ActiveRecord::Base
  include HasRecordProperty

  has_attached_file :data, path: ":rails_root/public/system/:class/:id_partition/:filename", url: "/system/:class/:id_partition/:filename"
  alias_attribute :name, :data_file_name

  has_many :spots
  has_many :attachings
  has_many :stones, through: :attachings, source: :attachable, source_type: "Stone"
  has_many :places, through: :attachings, source: :attachable, source_type: "Place"
  has_many :boxes, through: :attachings, source: :attachable, source_type: "Box"
  has_many :bibs, through: :attachings, source: :attachable, source_type: "Bib"
  has_many :analyses, through: :attachings, source: :attachable, source_type: "Analysis"

  attr_accessor :path

  def path
    id_partition = ("%08d" % id.to_s).scan(/\d{4}/).join("/")
    table_name = self.class.name.tableize
    "/system/#{table_name}/#{id_partition}/#{data_file_name}"
  end
end
