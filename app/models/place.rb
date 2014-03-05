class Place < ActiveRecord::Base
  include HasRecordProperty

  acts_as_mappable

  has_many :stones
  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings, as: :referable
  has_many :bibs, through: :referrings

  def country_name
    country_subdivisions = Geonames::WebService.country_subdivision "%0.2f" % latitude, "%0.2f" % longitude
    return "" if country_subdivisions.blank?
    country_subdivisions[0].country_name
  end

  def nearby_geonames
    geonames = Geonames::WebService.find_nearby "%0.2f" % latitude, "%0.2f" % longitude,{radius: 100,maxRows: 10,style: "FULL"}
    geonames

  end

  def readable_neighbors(current_user)
    places = Place.readables(current_user).where.not(id: self.id)
    places.each do |place|
      place.class.send(:attr_accessor, 'distance') if !place.respond_to?("distance=")
      place.send("distance=",place.distance_from(latitude,longitude))
    end

    sorted = places.sort{|a,b| a.distance <=> b.distance}
    sorted = sorted[0,10] if sorted.length > 10
    sorted
  end

  def distance_from(lat,lng)
    return Float::DIG if lat.blank? || lng.blank?
    return Float::DIG if latitude.blank? || longitude.blank?
    a = 6378.137 #radius of Earth in km
    dlat = Place.deg2rad(self.latitude - lat)
    dlng = Place.deg2rad(self.longitude - lng)
    dx = a * dlng * Math.cos(dlat)
    dy = a * dlat
    Math.sqrt(dx**2 + dy**2)
  end

private

  def self.deg2rad(deg)
    (deg/180)*Math::PI
  end

end
