class SurfaceLayerDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "fas fa-globe-asia") +
    " " + 
    h.link_to(surface.name, h.surface_path(surface)) + 
    " / #{self.name}"
    #h.raw(" < #{h.draggable_id(surface.global_id)} >")    
  end

  def published
    false
  end

  def calibrator(options)
    matrix = surface.affine_matrix_for_map
    return unless matrix
    surface_length = surface.length
    tilesize = surface.tilesize

    b_images = surface.surface_images.base
    unless b_images.empty?
      b_zooms = b_images.map{|b_image| Math.log(surface_length/tilesize * b_image.resolution, 2).ceil}
      b_bounds = b_images.map{|b_image| l, u, r, b = b_image.bounds; [[l,u],[r,b]] }
      lus = b_bounds.map{|a| a[0]}
      rbs = b_bounds.map{|a| a[1]}
      b_bounds_on_map = surface.coords_on_map(lus).zip(surface.coords_on_map(rbs))
    end
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
    a_corners_on_map = []
    s_images.each do |s_image|
      a_corners_on_map << surface.coords_on_map(s_image.image.corners_on_world)
    end
    layer_groups = []
    base_images = []
    b_images.each_with_index do |b_image, index|
      base_images << {id: b_image.image.try!(:id), name: b_image.image.try!(:name), bounds: b_image.image.bounds, path: b_image.data.url, width: b_image.image.width, height: b_image.image.height}
    end
    h_images = Hash.new
    s_images.each_with_index do |s_image, index|
      if s_image.wall
        base_images << {id: s_image.image.try!(:id), name: s_image.image.try!(:name), bounds: s_image.image.bounds, path: s_image.data.url, width: s_image.image.width, height: s_image.image.height}
      else
        layer_groups << {name: s_image.image.try!(:name), opacity: 100 }
        h_images[s_image.image.try!(:name)] = [{id: s_image.image.try!(:id), corners: s_image.image.corners_on_world, path: (s_image.image.fits_file? ? s_image.image.png_url : s_image.image.path), resource_url: h.surface_image_path(surface, s_image.image)}]
      end
    end
    h.content_tag(:div, nil, id: "surface-map", class: options[:class], data:{
                    base_url: Settings.map_url,
                    url_root: "#{Rails.application.config.relative_url_root}/",
                    global_id: surface.global_id,
                    length: surface.length,
                    center: surface.center,
                    base_images: base_images,
                    #layer_groups: layer_groups,
                    layer_groups: surface.wall_surface_layers.reverse.map { |layer| { id: layer.id, name: layer.name, opacity: layer.opacity, tiled: layer.tiled?, bounds: layer.bounds, max_zoom: layer.maxzoom, visible: layer.visible, wall: layer.wall, colorScale: layer.color_scale, displayMin: layer.display_min, displayMax: layer.display_max, resource_url: h.surface_layer_path(surface, layer) }},
                    images: h_images,
    })    
  end

  def fits_viewer(options)
    _range = self.default_display_range
    h.content_tag(:div, nil, id: "fits-viewer", class: options[:class], data:{
      base_url: Settings.map_url,
      display_max: (self.display_max.blank? ? _range[1] : self.display_max),
      display_min: (self.display_min.blank? ? _range[0] : self.display_min),
      opacity: self.opacity,
      color_scale: self.color_scale,
      fits_images: fits_surface_images.map { |s_image| { id: s_image.image.id, name: s_image.image.name, path: s_image.image.path, default_display_range:s_image.image.default_display_range }},
    }) do
      h.concat h.content_tag(:canvas, nil, id: "fits-canvas");
    end
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
                    #layer_groups: layer_groups,
                    layer_groups: surface.wall_surface_layers.reverse.map { |layer| { id: layer.id, name: layer.name, opacity: layer.opacity, tiled: layer.tiled?, bounds: layer.bounds, max_zoom: layer.maxzoom, visible: layer.visible, wall: layer.wall, colorScale: layer.color_scale, displayMin: layer.display_min, displayMax: layer.display_max, resource_url: h.surface_layer_path(surface, layer) }},
                    images: h_images,
                    spots: [],
                    bounds: m_bounds
    })
  end

  def panel_head_with_menu(tokens)
    h.content_tag(:div, class: "panel-heading") do
      h.concat(
        h.content_tag(:span, class: "panel-title pull-left") do
          h.concat(
              h.content_tag(:a, href: "#surface-layer-#{self.id}", data: {toggle: "collapse"}, 'aria-expanded' => false, 'aria-control' => "surface-layer-#{self.id}", title: "fold layer '#{self.name}'") do
              h.concat h.content_tag(:span, self.surface_images.size ,class: "badge")
              h.concat " "
              h.concat self.name
            end
          )
        end
      )
      h.concat h.raw("&nbsp;")
      h.concat h.content_tag(:span, "opacity: #{self.opacity}%", class: "label label-primary")
      if self.visible?
        h.concat h.content_tag(:span, "visible", class: "label label-primary")
      else
        h.concat h.content_tag(:span, "hidden", class: "label label-default")
      end
      h.concat h.raw("&nbsp;")
      tokens.each do |token|
        h.concat h.content_tag(:span, token, class: "label label-success")
      end
      h.concat(
        h.link_to(h.surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", method: :delete, title: "delete layer '#{self.name}'", data: {confirm: "Are you sure you want to delete layer '#{self.name}'"}) do
          h.concat h.content_tag(:span, nil, class: "fas fa-times")
        end
      )
      h.concat(
        h.link_to(h.move_to_top_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", method: :post, title: "move layer '#{self.name}' bottom") do
          h.concat h.content_tag(:span, nil, class: "fas fa-arrow-circle-down")
        end
      )
      h.concat(
        h.link_to(h.move_higher_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", method: :post, title: "move layer '#{self.name}' down") do
          h.concat h.content_tag(:span, nil, class: "fas fa-arrow-down")
        end
      )
      h.concat(
        h.link_to(h.move_lower_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", method: :post, title: "move layer '#{self.name}' up") do
          h.concat h.content_tag(:span, nil, class: "fas fa-arrow-up")
        end
      )
      h.concat(
        h.link_to(h.move_to_bottom_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", method: :post, title: "move layer '#{self.name}' top") do
          h.concat h.content_tag(:span, nil, class: "fas fa-arrow-circle-up")
        end
      )
      h.concat(
               h.link_to(h.edit_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", title: "edit name and opacity of layer '#{self.name}'") do
          h.concat h.content_tag(:span, nil, class: "fas fa-pencil-alt")
        end
      )
      h.concat(
        h.link_to(h.tiles_surface_layer_path(self.surface, self), method: :post, class: "btn btn-default btn-sm pull-right", title: "refresh tiles for images in layer '#{self.name}'") do
          h.concat h.content_tag(:span, nil, class: "fas fa-redo")
        end
      )
      h.concat(
        h.link_to(h.calibrate_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", title: "align images in layer '#{self.name}'") do
          h.concat h.content_tag(:span, nil, class: "fas fa-adjust")
        end
      )
      h.concat(
        h.link_to(h.map_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", title: "show images in layer '#{self.name}'") do
          h.concat h.content_tag(:span, nil, class: "fas fa-globe-asia")
        end
      )
      h.concat h.content_tag(:div, nil, class: "clearfix")
    end
  end

  def panel_head(tokens, &block)
    h.content_tag(:div, class: "panel-heading") do
      h.concat(
        h.content_tag(:span, class: "panel-title pull-left") do
          h.concat(
              h.content_tag(:a, href: "#surface-layer-#{self.id}", data: {toggle: "collapse"}, 'aria-expanded' => false, 'aria-control' => "surface-layer-#{self.id}", title: "fold layer '#{self.name}'") do
              h.concat h.content_tag(:span, self.calibrated_surface_images.size ,class: "badge")
              h.concat " "
              h.concat self.name
            end
          )
        end
      )
      h.concat h.raw("&nbsp;")
      if self.wall?
        h.concat h.content_tag(:span, "Base", class: "label label-primary")
      end
      h.concat h.content_tag(:span, "opacity: #{self.opacity}%", class: "label label-primary")
      if self.visible?
        h.concat h.content_tag(:span, "visible", class: "label label-primary")
      else
        h.concat h.content_tag(:span, "hidden", class: "label label-default")
      end
      h.concat h.raw("&nbsp;")
      tokens.each do |token|
        h.concat h.content_tag(:span, token, class: "label label-success")
      end
      if block_given?
        block.call
      end
    end
  end

  def drop_down_menu
    h.content_tag(:span, class: "dropdown") do
      h.concat(
          h.content_tag(:button, class: "btn btn-default btn-sm dropdown-toggle", :title => "dropdown menu for #{name}",  :type => "button", :id => "dropdownMenu1", 'data-toggle' => "dropdown", 'aria-haspopup' => true, 'aria-expanded' => false) do
          h.concat h.content_tag(:span, nil, class: "fas fa-ellipsis-h")
        end
      )
      h.concat(
        h.content_tag(:ul, class: "dropdown-menu", 'aria-labelledby' => "dropdownMenu1") do
          #h.concat h.content_tag(:li, h.link_to("show images in layer '#{self.name}'", h.map_surface_layer_path(self.surface, self), class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("edit name and opacity of layer '#{self.name}'", h.edit_surface_layer_path(self.surface, self), class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("align images in layer '#{self.name}'", h.calibrate_surface_layer_path(self.surface, self), class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("refresh tiles for images in layer '#{self.name}'", h.tiles_surface_layer_path(self.surface, self), method: :post, class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("move layer '#{self.name}' top", h.move_to_bottom_surface_layer_path(self.surface, self), method: :post, class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("move layer '#{self.name}' up", h.move_lower_surface_layer_path(self.surface, self), method: :post, class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("move layer '#{self.name}' down", h.move_higher_surface_layer_path(self.surface, self), method: :post, class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("move layer '#{self.name}' bottom", h.move_to_top_surface_layer_path(self.surface, self), method: :post, class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("delete layer '#{self.name}'", h.surface_layer_path(self.surface, self), method: :delete, data: {confirm: "Are you sure you want to delete layer '#{self.name}'"}, class: "dropdown-item"))          
        end
      )
    end    
  end

  def panel_menu
      #h.concat drop_down_menu
      #h.concat(
      #  h.link_to(h.surface_layer_path(self.surface, self), class: "btn btn-danger btn-sm pull-right", method: :delete, title: "delete layer '#{self.name}'", data: {confirm: "Are you sure you want to delete layer '#{self.name}'"}) do
      #    h.concat h.content_tag(:span, nil, class: "fas fa-times")
      #  end
      #)
      #h.concat(
      #  h.link_to(h.move_to_top_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm", method: :post, title: "move layer '#{self.name}' bottom") do
      #    h.concat h.content_tag(:span, nil, class: "fas fa-arrow-circle-down")
      #  end
      #)
      #h.concat(
      #  h.link_to(h.move_higher_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", method: :post, title: "move layer '#{self.name}' down") do
      #    h.concat h.content_tag(:span, nil, class: "fas fa-arrow-down")
      #  end
      #)
      #h.concat(
      #  h.link_to(h.move_lower_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", method: :post, title: "move layer '#{self.name}' up") do
      #    h.concat h.content_tag(:span, nil, class: "fas fa-arrow-up")
      #  end
      #)
      #h.concat(
      #  h.link_to(h.move_to_bottom_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm", method: :post, title: "move layer '#{self.name}' top") do
      #    h.concat h.content_tag(:span, nil, class: "fas fa-arrow-circle-up")
      #  end
      #)
      #h.concat(
      #         h.link_to(h.edit_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", title: "edit name and opacity of layer '#{self.name}'") do
      #    h.concat h.content_tag(:span, nil, class: "fas fa-pencil-alt")
      #  end
      #)
      h.concat h.raw("&nbsp;")
      h.concat(
        h.link_to(h.tiles_surface_layer_path(self.surface, self), method: :post, class: "btn btn-default btn-sm", title: "refresh tiles for images in layer '#{self.name}'") do
          h.concat h.content_tag(:span, nil, class: "fas fa-redo")
        end
      )
      #h.concat(
      #  h.link_to(h.calibrate_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", title: "align images in layer '#{self.name}'") do
      #    h.concat h.content_tag(:span, nil, class: "fas fa-adjust")
      #  end
      #)
      #h.concat(
      #  h.link_to(h.map_surface_layer_path(self.surface, self), class: "btn btn-default btn-sm pull-right", title: "show images in layer '#{self.name}'") do
      #    h.concat h.content_tag(:span, nil, class: "fas fa-globe-asia")
      #  end
      #)
      h.concat drop_down_menu
      h.concat h.content_tag(:div, nil, class: "clearfix")
    end

  def thumbnails_list(tokens, s_images = surface_images)
    h.content_tag(:ul, class: "list-inline thumbnails surface-layer", data: {id: self.id}, style: "min-height: 100px;" ) do
      #self.surface_images.reorder("position DESC").each do |surface_image|
      s_images.each do |surface_image|
        next unless surface_image.image
        next if surface_image.wall
        h.concat surface_image.decorate.li_thumbnail_for_js(tokens)
      end
    end
  end

  def panel_body(tokens)
    h.content_tag(:div, class: "panel-body collapse", id: "surface-layer-#{self.id}", data: {id: self.id, surface_id: self.surface_id}) do
      thumbnails_list(tokens, calibrated_surface_images)
    end
  end

  def panel_footer(tokens)
    h.content_tag(:div, class: "panel-footer", id: "surface-layer-#{self.id}") do
      thumbnails_list(tokens, uncalibrated_surface_images)
    end
  end

  def panel_with_block(&block)
    layer_tokens = []
    self.surface_images.each do |surface_image|
      image = surface_image.image
      #tokens = File.basename(image.name, ".*").split('-')
      tokens = surface_image.decorate.tokenize
      if layer_tokens.empty?
        layer_tokens = tokens
      else
        layer_tokens = layer_tokens & tokens
      end
    end
    h.content_tag(:div, class: "panel panel-default") do
      panel_head(layer_tokens) + h.content_tag(:div, class: "panel-body collapse", id: "surface-layer-#{self.id}") do
        block.call(layer_tokens)
      end
    end
  end

  def panel
    layer_tokens = []
    self.surface_images.each do |surface_image|
      image = surface_image.image
      #tokens = File.basename(image.name, ".*").split('-')
      tokens = surface_image.decorate.tokenize
      if layer_tokens.empty?
        layer_tokens = tokens
      else
        layer_tokens = layer_tokens & tokens
      end
    end
    t = panel_head(layer_tokens){ panel_menu } + panel_body(layer_tokens)
    t += panel_footer(layer_tokens) if uncalibrated_surface_images.size > 0
    h.content_tag(:div, class: "panel panel-default") do
      t
    end
  end
end
