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
      links << h.content_tag(:div, surface_image.decorate.spots_panel(spots: file.spots) , class: "col-lg-4") if file.image?
    end
    h.content_tag(:div, h.raw( links.join ), class: "row spot-thumbnails")
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
