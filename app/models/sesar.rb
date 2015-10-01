require "active_resource"

class Sesar < ActiveResource::Base
  self.site = "http://app.geosamples.org/"
  self.prefix = "/sample/"
  self.element_name = "sample"
  self.collection_name = "igsn"

  class Format
    include ActiveResource::Formats::XmlFormat

    def decode(xml)
      # レスポンスXMLにエスケープされていないアンパサンドが存在する
      super(xml.gsub("&", "&amp;"))
    end
  end
  self.format = Format.new

  def self.find(*arguments)
    super
  rescue ActiveResource::Redirection => e
    # 旧URLへのリダイレクト対策
    super(:one, from: e.response["location"])
  end
end
