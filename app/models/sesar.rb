# -*- coding: utf-8 -*-
require "active_resource"
require "geocoder"

class Sesar < ActiveResource::Base
  self.site = "https://app.geosamples.org/"
  self.user = Settings.sesar.user
  self.password = Settings.sesar.password
  self.prefix = "/sample/"
  self.element_name = "sample"
  self.collection_name = "igsn"

  schema do
    string    :user_code
    string    :sample_type
    string    :name
    string    :material
    string    :igsn
    string    :parent_igsn
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
    string    :vertical_datum
    string    :norting
    string    :easting
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
    string    :collector
    string    :collector_detail
    timestamp :collection_start_date
    timestamp :collection_end_date
    string    :collection_date_precision
    string    :current_archive
    string    :current_archive_contact
    string    :original_archive
    string    :original_archive_contact
    string    :depth_min
    string    :depth_max
    string    :depth_scale
    string    :external_url
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
    attributes[:sample_type] = model.physical_form.try!(:sesar_sample_type)
    attributes[:name] = model.name
    attributes[:sample_other_names] = [model.global_id]
    attributes[:material] = model.classification.try!(:sesar_material)
    attributes[:igsn] = model.igsn
    attributes[:classification] = array_classification(model.classification)
    attributes[:age_min] = model.age_min
    attributes[:age_max] = model.age_max
    attributes[:age_unit] = age_unit_conversion(model.age_unit)
    attributes[:size] = model.size.present? || model.size_unit.present? ? model.size : model.quantity
    attributes[:size_unit] = model.size.present? || model.size_unit.present? ? model.size_unit : model.quantity_unit
    attributes[:latitude] = model.place.try!(:latitude)
    attributes[:longitude] = model.place.try!(:longitude)
    attributes[:elevation] = model.place.try!(:elevation)
    attributes[:elevation_unit] = model.place.try!(:elevation) ? "meters" : ""
    result = Geocoder.search([attributes[:latitude], attributes[:longitude]])
    attributes[:country] = country_name(result[0])
    # 空で更新する場合、country属性ではSesarに反映されないためid属性を追加
    attributes[:country_id] = "" if attributes[:country].blank?
    attributes[:province] = province_name(result[0])
    attributes[:city] = city_name(result[0])
    attributes[:locality] = model.place.try!(:name)
    attributes[:locality_description] = model.place.try!(:description)
    attributes[:collector] = model.collector
    attributes[:collector_detail] = model.collector_detail
    attributes[:collection_start_date] = model.collected_at.try!(:strftime, "%Y-%m-%dT%H:%M:%SZ")
    attributes[:collection_end_date] = model.collected_end_at.try!(:strftime, "%Y-%m-%dT%H:%M:%SZ")
    attributes[:collection_date_precision] = model.collection_date_precision
    attributes[:current_archive] = Settings.sesar.archive_name
    attributes[:current_archive_contact] = Settings.sesar.archive_contact
    attributes[:external_urls] = external_url(model)
    attributes[:description] = model.description
    associate_specimen_custom_attributes(model).each do |sca|
      if sca.custom_attribute.sesar_name == "sample_other_names"
        attributes[:sample_other_names].concat( sca.value.split(",") )
      else
        attributes[sca.custom_attribute.sesar_name] = sca.value
      end
    end
    attributes.delete_if { |_, value| value.blank? } if model.igsn.blank?
    new(attributes)
  end

  def self.find(*arguments)
    super
  rescue ActiveResource::Redirection => e
    # 旧URLへのリダイレクト対策
    super(:one, from: e.response["location"])
  end

  def self.sync(model)
    return if model.igsn.blank?
    sesar_obj = self.find(model.igsn)
    sesar_sample = sesar_obj.sample
    model.name = sesar_sample.name

    sample_type = sesar_sample.sample_type
    if sample_type
      model.physical_form = PhysicalForm.find_or_create_by_sesar_sample_type(sample_type) do |physical_form|
        physical_form.name = sample_type
      end
    end
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
      results = Hash.from_xml(xml)['results']
      error = results.has_key?('sample') ? results['sample']['error'] : results['error']
      array = Array.wrap(error) rescue []
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

  def igsn_registered?
    attributes[:igsn].present?
  end

  def save
    post_path = igsn_registered? ? "/webservices/update.php" : "/webservices/upload.php"
    response = connection.post(post_path, post_params, post_headers)
    self.igsn = Hash.from_xml(response.body)["results"]["sample"]["igsn"]
    true
  rescue ActiveResource::BadRequest => e
    errors.from_xml(e.response.body)
    false
  end

  def to_xml(options ={})
    samples_schema = igsn_registered? ? update_samples_schema : upload_samples_schema

    xml = ""
    builder = Builder::XmlMarkup.new(target: xml)
    xml.clear
    builder.instruct!
    builder.samples(samples_schema) do |samples|
      samples.sample do |sample|
        attributes.each do |attr, values|
          case attr
          when "classification"
            classification_xml(builder, sample, values)
          when "material"
            sample << "<material>#{values}</material>"
          when "sample_other_names"
            sample_other_names_xml(sample, values)
          when "external_urls"
            external_urls_xml(sample, values)
          when "user_code"
            sample.tag!(attr, values) unless igsn_registered?
          else
            sample.tag!(attr, values)
          end
        end
      end
    end
    xml
  end

  def self.array_classification(classification)
    return "" if classification.blank?
    if classification.sesar_classification.present?
      classifications = classification.sesar_classification.split(">")
      classifications.unshift(classification.sesar_material)
    else
       ""
    end
  end
  
  def self.country_name(result)
    return "" if result.blank? || result.address.blank?
    result.country
  end
  
  def self.province_name(result)
    return "" if result.blank? || result.address.blank?
    result.state
  end
  
  def self.city_name(result)
    return "" if result.blank? || result.address.blank?
    result.city
  end
  
  def self.external_url(model)
    urls = Array(Settings.sesar.external_urls).each_with_object([]) do |external_url, array|
      array << {
        url: external_url.url.gsub(/\#{([^{}]+)}/) { model.send($1.to_sym) rescue nil },
        description: external_url.description,
        url_type: external_url.url_type
      }
    end
    if model.bibs.present?
      model.bibs.each do |bib|
        next if bib.doi.blank?
        urls.push({url: "https://doi.org/#{bib.doi}", description: bib.name, url_type: "DOI"})
      end
    end
    urls
  end

  def self.associate_specimen_custom_attributes(model)
    SpecimenCustomAttribute.joins(:custom_attribute).includes(:custom_attribute)\
      .where(specimen_id: model.id)\
      .where.not(value: nil)\
      .where.not(value: '')\
      .where.not(custom_attributes: {sesar_name: nil})\
      .where.not(custom_attributes: {sesar_name: ''})
  end

  def self.age_unit_conversion(age_unit)
    return "" if age_unit.blank?
    age_unit_list = YAML.load(File.read("#{Rails.root}/config/age_unit.yml"))

    if age_unit_list.has_key?(age_unit)
      age_unit == "a" ? age_unit_list[age_unit] : "#{age_unit_list[age_unit]} (#{age_unit})"
    else
      age_unit
    end
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

  def upload_samples_schema
    {
      "xmlns" => "http://app.geosamples.org",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" => "http://app.geosamples.org/4.0/sample.xsd"
    }
  end

  def update_samples_schema
    {
      "xmlns" => "http://app.geosamples.org",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" => "http://app.geosamples.org/4.0/updateSample.xsd"
    }
  end

  def classification_schema
    {
      "xmlns" => "http://app.geosamples.org",
      "xmlns:xs" => "http://www.w3.org/2001/XMLSchema",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" => "http://app.geosamples.org/classifications.xsd"
    }
  end
  
  def classification_xml(builder, sample, values)
    builder.classification(classification_schema) do
      build_classification_part(sample, values) do |values|
        if values.blank?
          ""
        elsif values[0].end_with?("Type")
          sample.tag!(values[0], values[1])
        else
          sample.tag!(values[0]) do
            sample.tag!(values[1])
          end
        end
      end
    end
  end
  
  def build_classification_part(sample, values, &block)
    if values.size > 2
      first = values.shift
      sample.tag!(first) do
        build_classification_part(sample, values, &block)
      end
    else
      block.call values
    end
  end
  
  def sample_other_names_xml(sample, values)
    sample.sample_other_names do
      values.each do |value|
        sample.sample_other_name(value)
      end
    end
  end
  
  def external_urls_xml(sample, values)
    sample.external_urls do
      values.each do |value|
        sample.external_url do
          sample.url(value.attributes["url"])
          sample.description(value.attributes["description"])
          sample.url_type(value.attributes["url_type"])
        end
      end
    end
  end

end
