module HasAttachmentFile
  extend ActiveSupport::Concern
  
  included do
    has_many :attachings, -> { order('position asc') }, as: :attachable, dependent: :destroy
    has_many :attachment_files, through: :attachings

    delegate :thumbnail_path, to: :primary_file, prefix: true, allow_nil: true
  end

  def primary_file
    attachment_files.first
  end

  def attachment_pdf_files
    attachment_files.where(AttachmentFile.arel_table[:data_content_type].matches('%/pdf'))
  end

  def attachment_image_files
    attachment_files.where(AttachmentFile.arel_table[:data_content_type].matches('image/%'))
  end
end
