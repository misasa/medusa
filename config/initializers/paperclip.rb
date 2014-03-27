require 'paperclip/railtie'
module Paperclip
  module Interpolations
    def id_partition(attachment_file, style_name)
      ("%08d" % attachment_file.instance.id).scan(/\d{4}/).join("/")
    end

    def basename_with_style(attachment_file, style_name)
      basename = attachment_file.original_filename.gsub(/#{File.extname(attachment_file.original_filename)}$/, "")
      if style_name.present? && !(style_name == attachment_file.default_style)
        basename += "_#{style_name}"
      end
      basename
    end
  end 
end