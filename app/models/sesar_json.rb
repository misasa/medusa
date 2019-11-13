# -*- coding: utf-8 -*-
require "active_resource"

class SesarJson < ActiveResource::Base
  self.site = "https://app.geosamples.org/"
  self.user = Settings.sesar.user
  self.password = Settings.sesar.password
  self.prefix = "/sample/"
  self.element_name = "sample"
  self.collection_name = "igsn"
  self.include_format_in_path = false

  attr_reader :error_message

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

  def initialize(attributes = {}, persisted = false)
    attributes[:user_code] ||= Settings.sesar.user_code
    super
  end

  class Classification
    attr_reader :attributes
    def initialize(attributes = {}, persisted = false)
      @attributes = attributes
      @prefix_options = {}
      @persisted = persisted
    end
  end

  class Errors < ActiveResource::Errors
    def from_json(json, save_cache = false)
      decoded = ActiveSupport::JSON.decode(json) || {} rescue {}
      decoded = decoded['sample'] if decoded.has_key?('sample')

      if decoded.has_key?('error')
        @messages = decoded['error']
      elsif decoded.has_key?('status')
        @messages = decoded['status']
      else
        @messages = "Unable to parse error message."
      end
    end
  end

  def errors
    @errors ||= Errors.new(self)
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
  rescue ActiveResource::BadRequest, ActiveResource::ForbiddenAccess, ActiveResource::ResourceNotFound => e
    sesar_obj = SesarJson.new
    sesar_obj.load_remote_errors(e)
    sesar_obj
  end

  def update_specimen(specimen)
    specimen.place = get_place_model(specimen)
    specimen.physical_form = get_physical_form_model
    specimen.classification = get_classification_model
    specimen.save
    
    params = {}
    params[:name] = @attributes["name"]
    params[:description] = @attributes["description"]
    params[:age_min] = @attributes["age_min"]
    params[:age_max] = @attributes["age_max"]
    params[:age_unit] = get_age_unit(@attributes["age_unit"])
    params[:size] = @attributes["size"]
    params[:size_unit] = @attributes["size_unit"]
    params[:collected_at] = @attributes["collection_start_date"].blank? ? nil : DateTime.parse(@attributes["collection_start_date"])
    params[:collected_end_at] = @attributes["collection_end_date"].blank? ? nil : DateTime.parse(@attributes["collection_end_date"])
    params[:collection_date_precision] = @attributes["collection_date_precision"]
    params[:collector] = @attributes["collector"]
    params[:collector_detail] = @attributes["collector_detail"]
    specimen.update_attributes(params)

    associate_specimen_custom_attributes(specimen).each do |sca|
      specimen_custom_attribute = SpecimenCustomAttribute.find_by(specimen_id: sca.specimen_id, custom_attribute_id: sca.custom_attribute_id)
      specimen_custom_attribute.update(value: @attributes[sca.custom_attribute.sesar_name])
    end
  end

  def associate_specimen_custom_attributes(model)
    SpecimenCustomAttribute.joins(:custom_attribute).includes(:custom_attribute)\
      .where(specimen_id: model.id)\
      .merge(CustomAttribute.where.not(sesar_name: [ nil, '', 'sample_other_names' ]))
  end

  def get_classification_model
    material = @attributes["material"]
    classification_obj = @attributes["classification"]

    return if classification_obj.nil? || classification_obj.attributes.empty? || classification_obj.attributes[material].blank?

    classifications = get_all_keys(classification_obj.attributes[material])
    classification = nil
    sesar_classification = ""
    parent_id = nil;

    classifications.each do |classification_item|
      sesar_classification += ">" if sesar_classification.present?
      sesar_classification += classification_item

      classification = ::Classification.find_or_create_by(sesar_material: material, sesar_classification: sesar_classification) do |classification|
        classification.name = classification_item
        classification.parent_id = parent_id
        classification.sesar_material = material
        classification.sesar_classification = sesar_classification
      end
      parent_id = classification.id
    end
    classification
  end

  def get_physical_form_model
    sample_type = @attributes["sample_type"]
    return if sample_type.nil?

    physical_form = PhysicalForm.find_or_create_by(sesar_sample_type: sample_type) do |physical_form|
      physical_form.name = sample_type
    end
  end

  def get_place_model(specimen)
    locality = @attributes["locality"]
    locality_description = @attributes["locality_description"]
    latitude = @attributes["latitude"] 
    longitude = @attributes["longitude"]
    elevation = @attributes["elevation"]
    elevation_unit = @attributes["elevation_unit"]

    return if locality.nil? && locality_description.nil? && latitude.nil? && longitude.nil? && elevation.nil?

    locality = "locality of #{specimen.name}" unless locality
    elevation = elevation_conversion(elevation, elevation_unit)
    place = Place.find_by(latitude: latitude, longitude: longitude, elevation: elevation)

    if place
      place.skip_conversion = true
      place.update(name: locality, description: locality_description)
    else
      place = Place.new do |place|
        place.name = locality
        place.description = locality_description
        place.latitude = latitude
        place.longitude = longitude
        place.elevation = elevation
      end
      place.skip_conversion = true
      place.save
    end
    place
  end

  def elevation_conversion(elevation, elevation_unit)
    return if elevation.blank?
    elevation = elevation.to_f

    case elevation_unit
    when "kilometers"
      elevation.kilometers.to.meters.to_f
    when "feet"
      elevation.feet.to.meters.to_f
    when "miles"
      elevation.miles.to.meters.to_f
    else
      elevation
    end
  end

  private

  def get_all_keys(arg)
    all_keys = []
    case arg
    when Hash
      arg.each do |k,v|
        all_keys << k
        all_keys.concat get_all_keys(v)
      end
    when Array
      arg.each do |v|
        all_keys.concat get_all_keys(v)
      end
    end
    all_keys
  end

  def get_age_unit(sesar_age_unit)
    return if sesar_age_unit.nil?
    age_unit_list = YAML.load(File.read("#{Rails.root}/config/age_unit.yml"))

    age_unit_list.each do |k, v|
      if sesar_age_unit.match(/^#{v}.*/) || sesar_age_unit == k
        return k
      else
        nil
      end
    end
  end

end