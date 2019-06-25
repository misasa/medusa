class SurfaceLayerDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-globe") +
    " " + 
    h.link_to(surface.name, h.surface_path(surface)) + 
    " / #{self.name}"
    #h.raw(" < #{h.draggable_id(surface.global_id)} >")    
  end

  def published
    false
  end

  def map(options)
    matrix = surface.affine_matrix_for_map
    return unless matrix
    surface_length = surface.length
    tilesize = surface.tilesize

    s_images = surface_images.reverse
    a_zooms = s_images.map{|s_image| Math.log(surface_length/tilesize * s_image.resolution, 2).ceil}
    a_bounds = s_images.map{|s_image| l, u, r, b = s_image.bounds; [[l,u],[r,b]] }
    lus = a_bounds.map{|a| a[0]}
    rbs = a_bounds.map{|a| a[1]}
    a_bounds_on_map = surface.coords_on_map(lus).zip(surface.coords_on_map(rbs))

    left = a_bounds_on_map.map{|v| v[0][0]}.min
    upper = a_bounds_on_map.map{|v| v[0][1]}.min
    right = a_bounds_on_map.map{|v| v[1][0]}.max
    bottom = a_bounds_on_map.map{|v| v[1][1]}.max
    m_bounds = [[left, upper],[right,bottom]]
    layer_groups = []
    base_images = []
    h_images = Hash.new
    s_images.each_with_index do |s_image, index|
      if s_image.wall
        base_images << {id: s_image.image.try!(:id), name: s_image.image.try!(:name), bounds: a_bounds_on_map[index], max_zoom: a_zooms[index]}
      else
        layer_groups << {name: s_image.image.try!(:name), opacity: 100 }
        h_images[s_image.image.try!(:name)] = [{id: s_image.image.try!(:id), bounds: a_bounds_on_map[index], max_zoom: a_zooms[index]}]
      end
    end
    h.content_tag(:div, nil, id: "surface-map", class: options[:class], data:{
                    base_url: Settings.map_url,
                    url_root: "#{Rails.application.config.relative_url_root}/",
                    global_id: surface.global_id,
                    length: surface.length,
                    matrix: matrix.inv,
                    add_spot: true,
                    add_radius: true,
                    base_images: base_images,
                    layer_groups: layer_groups,
                    images: h_images,
                    spots: [],
                    bounds: m_bounds
    })
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
               h.link_to(h.tiles_surface_layer_path(self.surface, self), method: :post, class: "btn btn-default btn-sm pull-right", title: "force create tiles") do
          h.concat h.content_tag(:span, nil, class: "glyphicon glyphicon-refresh")
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
      #self.surface_images.reorder("position DESC").each do |surface_image|
      surface_images.each do |surface_image|
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
