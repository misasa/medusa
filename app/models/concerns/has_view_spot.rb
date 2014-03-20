module HasViewSpot
  extend ActiveSupport::Concern

  def has_image?
    attachment_files.present? && attachment_files.any? {|file| file.image? }
  end

  module ClassMethods
  end

end
