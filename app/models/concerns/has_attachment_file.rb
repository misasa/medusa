module HasAttachmentFile
  extend ActiveSupport::Concern
  
  included do
    has_many :attachings, as: :attachable, dependent: :destroy
    has_many :attachment_files, through: :attachings
  end

  def attachment_pdf_files
    attachment_files.where(AttachmentFile.arel_table[:data_content_type].matches('%/pdf'))
  end

  def attachment_image_files
    attachment_files.where(AttachmentFile.arel_table[:data_content_type].matches('image/%'))
  end
end