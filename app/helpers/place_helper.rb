module PlaceHelper

  def format_latitude(latitude)
    if latitude < 0
      la = "%.4f S"%(latitude * -1)
    else
      la = "%.4f N"%latitude
    end
    la
  end

  def format_longitude(longitude)
    if longitude < 0
      lo = "%.4f W"%(longitude * -1)
    else
      lo = "%.4f E"%longitude.to_s
    end
    lo
  end

  def format_elevation(elevation)
    return "" unless elevation
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

end
