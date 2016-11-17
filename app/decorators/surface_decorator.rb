class SurfaceDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def name_with_id
    tag = h.content_tag(:span, nil, class: "glyphicon glyphicon-globe") + " #{name} < #{global_id} >"
    if Settings.rplot_url
      tag += h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-eye-open"), Settings.rplot_url + '?id=' + global_id, :title => 'plot online')
    end
    tag    
  end


  def to_tex
    surface_images[0].decorate.to_tex unless surface_images.empty?
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
