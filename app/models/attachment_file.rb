class AttachmentFile < ActiveRecord::Base
  include HasRecordProperty

  has_attached_file :data, path: ":rails_root/public/system/:class/:id/:filename", url: "/system/:class/:id/:filename"

  has_many :spots
  has_many :attachings
  has_many :stones, through: :attachings, source: :attachable, source_type: "Stone"
  has_many :places, through: :attachings, source: :attachable, source_type: "Place"
  has_many :boxes, through: :attachings, source: :attachable, source_type: "Box"
  has_many :bibs, through: :attachings, source: :attachable, source_type: "Bib"
  has_many :analyses, through: :attachings, source: :attachable, source_type: "Analysis"

  attr_accessor :path

  def path
    "/system/attachment_files/" + id.to_s + "/" + data_file_name
  end
end
