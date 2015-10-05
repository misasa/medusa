require "active_resource"

class Sesar < ActiveResource::Base
  self.site = "http://app.geosamples.org/"
  self.user = Settings.sesar.user
  self.password = Settings.sesar.password
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

  def save
    response = connection.post("/webservices/upload.php", "username=#{self.class.user}&password=#{self.class.password}&content=#{encode}&submit=submit", "Content-Type" => "application/x-www-form-urlencoded")
    self.igsn = Hash.from_xml(response.body)["results"]["sample"]["igsn"]
    true
  rescue ActiveResource::BadRequest => e
    # TODO: 失敗した理由をレスポンスXMLから取得してユーザに通知すべき
    false
  end

  def to_xml(options ={})
    xml = ""
    builder = Builder::XmlMarkup.new(target: xml)
    xml.clear
    builder.instruct!
    builder.samples("xmlns" => "http://app.geosamples.org", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xsi:schemaLocation" => "http://app.geosamples.org/samplev2.xsd") do |samples|
      samples.sample do |sample|
        # TODO: 設定内容はダミー
        sample.user_code Settings.sesar.user_code
        sample.sample_type "Individual Sample"
        sample.name "test"
        sample.material "Rock"
      end
    end
    xml
  end
end
