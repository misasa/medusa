module PlaceHelper

  def format_latitude(latitude)
    return "" if latitude.blank?
    if latitude < 0
      la = "%.4f S" % (latitude * -1)
    else
      la = "%.4f N" % latitude
    end
    la
  end

  def format_longitude(longitude)
    return "" if longitude.blank?
    if longitude < 0
      lo = "%.4f W" % (longitude * -1)
    else
      lo = "%.4f E" % longitude.to_s
    end
    lo
  end

  def format_elevation(elevation)
    return "" if elevation.blank?
    return elevation.to_s
  end

  def format_stones_summary(stones,length = 10)
    l = stones.map{|s| s.name }
    text = l.join(', ')
    if length
      if text.size > length
        text = text.slice(0,length) + ' ...'
      end
    end
    text + " [#{stones.count}]"
  end

  def format_stones_count(stones)
    stones.count > 0 ? stones.count.to_s : ""
  end

end
