# -*- coding: utf-8 -*-
class PlaceDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-globe") + " #{name} < #{global_id} >"
  end

  def latitude_to_text
    return "" if latitude.blank?
    if latitude < 0
      la = "%.4f S" % (latitude * -1)
    else
      la = "%.4f N" % latitude
    end
    la
  end

  def longitude_to_text
    return "" if longitude.blank?
    if longitude < 0
      lo = "%.4f W" % (longitude * -1)
    else
      lo = "%.4f E" % longitude.to_s
    end
    lo
  end

  def elevation_to_text
    return "" if elevation.blank?
    return elevation.to_s
  end

  def stones_summary(length = 10)
    l = stones.map{|s| s.name }
    text = l.join(', ')
    if length
      if text.size > length
        text = text.slice(0,length) + ' ...'
      end
    end
    text + " [#{stones.count}]"
  end

  def stones_count
    stones.count > 0 ? stones.count.to_s : ""
  end

  def country_name
    return "" if latitude.blank? || longitude.blank?
    country_subdivisions = Geonames::WebService.country_subdivision "%0.2f" % latitude, "%0.2f" % longitude
    return "" if country_subdivisions.blank?
    country_subdivisions[0].country_name
  end

  def nearby_geonames
    return [] if latitude.blank? || longitude.blank?
    geonames = Geonames::WebService.find_nearby "%0.2f" % latitude, "%0.2f" % longitude,{radius: 100,maxRows: 10,style: "FULL"}
    geonames

  end

  def readable_neighbors(current_user)
    places = Place.readables(current_user).where.not(id: self.id).decorate
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
    dlat = PlaceDecorator.deg2rad(self.latitude - lat)
    dlng = PlaceDecorator.deg2rad(self.longitude - lng)
    dx = a * dlng * Math.cos(dlat)
    dy = a * dlat
    Math.sqrt(dx**2 + dy**2)
  end

private

  def self.deg2rad(deg)
    (deg/180)*Math::PI
  end

end
