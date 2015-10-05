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

  class Errors < ActiveResource::Errors
    def from_array(messages, save_cache = false)
      reg = /Element '{http:\/\/app.geosamples.org}(\w*)'(.*)/
      messages.each do |message|
        _, attr, msg = *reg.match(message).to_a
        attr ||= :base
        msg ||= message
        add(attr, msg)
      end
    end

    def from_xml(xml, save_cache = false)
      array = Array.wrap(Hash.from_xml(xml)['results']['error']) rescue []
      from_array(array, save_cache)
    end
  end

  def errors
    @errors ||= Errors.new(self)
  end

  def save
    response = connection.post("/webservices/upload.php", "username=#{self.class.user}&password=#{self.class.password}&content=#{encode}&submit=submit", "Content-Type" => "application/x-www-form-urlencoded")
    self.igsn = Hash.from_xml(response.body)["results"]["sample"]["igsn"]
    true
  rescue ActiveResource::BadRequest => e
    errors.from_xml(e.response.body)
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
