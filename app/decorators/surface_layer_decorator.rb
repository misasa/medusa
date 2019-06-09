class SurfaceLayerDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-globe") +
    " " + 
    h.link_to(surface.name, h.surface_path(surface)) + 
    " / #{self.name}"
    #h.raw(" < #{h.draggable_id(surface.global_id)} >")    
  end

  def map(options = {})
    matrix = surface.decorate.affine_matrix_for_map
    return unless matrix
    left, upper, right, bottom = bounds
    h.content_tag(:div, nil, id: "surface-map", class: options[:class], data:{
                    base_url: Settings.map_url,
                    url_root: "#{Rails.application.config.relative_url_root}/",
                    global_id: surface.global_id,
                    length: surface.length,
                    matrix: matrix.inv,
                    add_spot: true,
                    add_radius: true,
                    base_images: surface_images.wall.map{|s_image| {id: s_image.image.try!(:id), name: s_image.image.try!(:name), bounds: s_image.decorate.bounds_on_map } },
                    #base_image: {id: image.id, name: image.name, bounds: [] },
                    layer_groups: surface_images.overlay.map{|s_image| {name: s_image.image.name, opacity: 100 }},
                      images: surface_images.overlay.each_with_object(Hash.new {|h, k| h[k] = []}) {|s_image, hash|  hash[s_image.image.name] << {id: s_image.image.id, bounds: s_image.decorate.bounds_on_map}},
                    spots: [],
                    bounds: [[left, upper],[right, bottom]].map{|world_x, world_y|
                      x = matrix[0, 0] * world_x + matrix[0, 1] * world_y + matrix[0, 2]
                      y = matrix[1, 0] * world_x + matrix[1, 1] * world_y + matrix[1, 2]
                      [x, y]
                    }
    })
  end

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
      h.concat(
               h.link_to(h.map_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", title: "show images on map") do
          h.concat h.content_tag(:span, nil, class: "glyphicon glyphicon-globe")
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
