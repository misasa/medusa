ActionController::Renderers.add :svg do |obj, options|
  %Q|<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">#{obj.to_svg}</svg>|
end

class ActiveRecord::Relation
  def to_svg
    map(&:to_svg).join("")
  end
end
