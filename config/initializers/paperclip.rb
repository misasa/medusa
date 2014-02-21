require 'paperclip/railtie'
module Paperclip
  module Interpolations
    def id_partition(attachment_file, style_name)
      ("%08d" % attachment_file.instance.id).scan(/\d{4}/).join("/")
    end
  end 
end