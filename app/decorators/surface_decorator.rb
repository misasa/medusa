class SurfaceDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  # def rplot_url
  #   return unless Settings.rplot_url
  #   Settings.rplot_url + '?id=' + global_id
  # end

  def name_with_id
    tag = h.content_tag(:span, nil, class: "glyphicon glyphicon-globe") + " #{name} < #{global_id} >"
    # if Settings.rplot_url
    #   tag += h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-eye-open"), rplot_url, :title => 'plot online')
    # end
    tag    
  end

    # def rplot_iframe(size = '600')
    #   tag = h.content_tag(:iframe, nil, src: rplot_url, width: size, height: size, frameborder: "no", class: "embed-responsive-item")
    # end

  def to_tex
    surface_images[0].decorate.to_tex unless surface_images.empty?
  end

  def related_pictures
    links = []
    surface_images.order("position ASC").each do |surface_image|
      file = surface_image.image
      links << h.content_tag(:div, surface_image.decorate.spots_panel(spots: file.spots) , class: "col-lg-3") if file.image?
    end
    h.content_tag(:div, h.raw( links.join ), class: "row spot-thumbnails")
  end

  def spots_panel(width: 40, height:40, spots:[])
    surface = self
    file = self.first_image
    svg = file.decorate.picture_with_spots(width:width, height:height, spots:spots)
    svg_link = h.link_to(h.surface_image_path(surface, file)) do
      svg
    end
    left = h.content_tag(:div, svg_link, class: "col-md-12")
    right = h.content_tag(:div, nil, class: "col-md-12")
    row = h.content_tag(:div, left + right, class: "row")
    header = h.content_tag(:div, class: "panel-heading") do
    end

    body = h.content_tag(:div, row, class: "panel-body")
    tag = h.content_tag(:div, body, class: "panel panel-default")
    tag
  end


  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
