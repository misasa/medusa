require "active_resource"

class Sesar < ActiveResource::Base
  self.site = "http://app.geosamples.org/"
  self.user = Settings.sesar.user
  self.password = Settings.sesar.password
  self.prefix = "/sample/"
  self.element_name = "sample"
  self.collection_name = "igsn"

  # TODO: 一旦すべてを列挙。必要ないものは削除する
  schema do
    string    :user_code
    string    :sample_type
    string    :name
    string    :material
    string    :igsn
    string    :parent_igsn
    # is_private
    # publish_date
    string    :classification
    string    :classification_comment
    string    :field_name
    string    :description
    decimal   :age_min
    decimal   :age_max
    string    :age_unit
    string    :geological_age
    string    :geological_unit
    string    :collection_method
    string    :collection_method_descr
    string    :size
    string    :size_unit
    string    :sample_comment
    string    :purpose
    decimal   :latitude
    decimal   :longitude
    decimal   :latitude_end
    decimal   :longitude_end
    decimal   :elevation
    decimal   :elevation_end
    string    :vartical_datum
    decimal   :northing
    decimal   :easting
    # zone
    string    :navigation_type
    string    :primary_location_type
    string    :primary_location_name
    string    :location_description
    string    :locality
    string    :locality_description
    string    :country
    string    :province
    string    :county
    string    :city
    string    :cruise_field_prgrm
    string    :platform_type
    string    :platform_name
    string    :platform_descr
    string    :launch_platform_name
    string    :launch_id
    string    :launch_type_name
    string    :collector
    string    :collector_detail
    timestamp :collection_start_date
    timestamp :collection_end_date
    string    :collection_date_precision
    string    :current_archive
    string    :current_archive_contact
    string    :original_archive
    string    :original_archive_contact
    decimal   :depth_min
    decimal   :depth_max
    string    :depth_scale
    # sample_other_names
    # external_url
  end

  class Format
    include ActiveResource::Formats::XmlFormat

    def decode(xml)
      # レスポンスXMLにエスケープされていないアンパサンドが存在する
      super(xml.gsub("&", "&amp;"))
    end
  end
  self.format = Format.new

  def self.from_active_record(model)
    attributes = {}
    # TODO: DBとXMLのマッピングを確定させて、実装に反映すること
    # attributes[:sample_type] = "Core"
    attributes[:name] = model.name
    # attributes[:meterial] = "Rock"
    attributes[:description] = model.description
    attributes[:latitude] = model.place.try!(:latitude)
    attributes[:longitude] = model.place.try!(:longitude)
    attributes[:elevation] = model.place.try!(:elevation)
    attributes.delete_if { |_, value| value.blank? }
    new(attributes)
  end

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

  def initialize(attributes = {}, persisted = false)
    attributes[:user_code] ||= Settings.sesar.user_code
    super
  end

  def save
    response = connection.post("/webservices/upload.php", post_params, post_headers)
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
    builder.samples(samples_schema) do |samples|
      samples.sample do |sample|
        attributes.each do |attr, value|
          sample.__send__(attr, value)
        end
      end
    end
    xml
  end

  private

  def post_params
    {
      username: self.class.user,
      password: self.class.password,
      content:  encode
    }.to_query
  end

  def post_headers
    {
      "Content-Type" => "application/x-www-form-urlencoded"
    }
  end

  def samples_schema
    {
      "xmlns" => "http://app.geosamples.org",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" => "http://app.geosamples.org/samplev2.xsd"
    }
  end
end
