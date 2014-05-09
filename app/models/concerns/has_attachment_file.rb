module HasAttachmentFile
  extend ActiveSupport::Concern
  
  def attachment_pdf_files
    self.attachment_files.select{|attachment_file| attachment_file.pdf?}
  end
end