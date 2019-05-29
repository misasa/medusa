class SurfaceLayerDecorator < Draper::Decorator
  delegate_all

  def published
    false
  end

  def panel_head
    h.content_tag(:div, class: "panel-heading") do
      h.concat(
        h.content_tag(:span, class: "panel-title pull-left") do
          h.concat(
                   h.content_tag(:a, href: "#surface-layer-#{self.id}", data: {toggle: "collapse"}, 'aria-expanded' => false, 'aria-control' => "surface-layer-#{self.id}", title: "show and hide images belong to #{self.name}") do
              h.concat h.content_tag(:span, self.surface_images.size ,class: "badge")
              h.concat " "
              h.concat self.name
            end
          )
        end
      )
      h.concat h.content_tag(:span, "opacity: #{self.opacity}%", class: "label label-primary pull-left")
      h.concat(
        h.link_to(h.surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", method: :delete, title: "delete layer #{self.name}", data: {confirm: "Are you sure you want to delete layer #{self.name}"}) do
          h.concat h.content_tag(:span, nil, class: "glyphicon glyphicon-remove")
        end
      )
      h.concat(
        h.link_to(h.move_to_top_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", title: "move to bottom") do
          h.concat h.content_tag(:span, nil, class: "glyphicon glyphicon-arrow-down")
        end
      )
      h.concat(
               h.link_to(h.edit_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", title: "edit name or opacity layer") do
          h.concat h.content_tag(:span, nil, class: "glyphicon glyphicon-pencil")
        end
      )
      h.concat h.content_tag(:div, nil, class: "clearfix")
    end
  end

  def thumbnails_list
    h.content_tag(:ul, class: "list-inline thumbnails surface-layer", data: {id: self.id}, style: "min-height: 100px;" ) do
      self.surface_images.reorder("position DESC").each do |surface_image|
        next unless surface_image.image
        h.concat surface_image.decorate.li_thumbnail
      end
    end
  end

  def panel_body
    h.content_tag(:div, class: "panel-body collapse in", id: "surface-layer-#{self.id}") do
      thumbnails_list
    end
  end

  def panel
    h.content_tag(:div, class: "panel panel-default") do
      panel_head + panel_body
    end
  end
end
