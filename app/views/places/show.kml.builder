xml.instruct! :xml, :version => "1.0"
xml.kml(xmlns: "http://www.opengis.net/kml/2.2") do |kml|
  kml.Placemark do |place_mark|
    place_mark.name @place.name
    place_mark.description @place.description
    place_mark.Point do |point|
      point.coordinates "#{@place.latitude},#{@place.longitude},#{@place.elevation}"
    end
  end
end
