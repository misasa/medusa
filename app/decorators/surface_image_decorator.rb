class SurfaceImageDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers	
  delegate_all
  delegate :as_json


  def as_json(options = {})
    super({ methods: [:image]}.merge(options))
  end
  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def name_with_id
    h.content_tag(:span, nil, class: "fas fa-globe-asia") +
    " " + 
    h.link_to(surface.name, h.surface_path(surface)) + 
    " / #{image.name}"
    #h.raw(" < #{h.draggable_id(surface.global_id)} >")    
  end
 
  def tokenize
    File.basename(self.image.name, ".*").split(/-|_|@/)
  end

  def tile_path(zoom,x,y)
    return unless image
    path = h.url_for_tile(self) + "#{image.id}/#{zoom}/#{x}_#{y}.png"
  end

  def calibrator(b_images, options)
    surface_length = surface.length
    tilesize = surface.tilesize
    return unless image
    s_images = surface.surface_images.calibrated.reverse
    a_zooms = s_images.map{|s_image| Math.log(surface_length/tilesize * s_image.resolution, 2).ceil if s_image.resolution }
    layer_groups = []
    base_images = []
    h_images = Hash.new
    s_images.each_with_index do |s_image, index|
      if s_image.wall
        base_images << {id: s_image.image.try!(:id), name: s_image.image.try!(:name), bounds: s_image.image.bounds, max_zoom: a_zooms[index]}
      else
        layer_group_name = s_image.surface_layer.try!(:name) || 'top'
        h_images[layer_group_name] = [] unless h_images.has_key?(layer_group_name)
        h_images[layer_group_name] << {id: s_image.image.try!(:id), bounds: s_image.image.bounds, max_zoom: a_zooms[index], fits_file: s_image.image.fits_file?, corners: s_image.corners_on_world, path: s_image.image.path}
      end
    end

#    base_images = []
#    if b_images.empty?
#      b_images = surface.wall_surface_images
      #b_images.concat(surface.wall_surface_layers.map{|l| l.surface_images}.flatten)
#    end
#    b_images.each do |b_image|
#      base_images << {name: b_image.name, path: b_image.data.url, width: b_image.image.width, height: b_image.image.height, id: b_image.image.try!(:id), bounds: b_image.bounds}
#    end

    h.content_tag(:div, nil, id: "surface-map", class: options[:class], data:{
                    base_url: Settings.map_url,
                    url_root: "#{Rails.application.config.relative_url_root}/",
                    global_id: surface.global_id,
                    length: surface.length,
                    center: surface.center,
                    #base_images: [{path: b_images[0].data.url, width: b_images[0].image.width, height: b_images[0].image.height, id: b_images[0].image.try!(:id), bounds: b_images[0].bounds}],
                    base_images: base_images,                    
                    #layer_groups: [{name: image.try!(:name), opacity: 100 }],
                    layer_groups: surface.wall_surface_layers.reverse.map { |layer| { id: layer.id, name: layer.name, opacity: layer.opacity, tiled: layer.tiled?, bounds: layer.bounds, max_zoom: layer.maxzoom, visible: layer.visible, wall: layer.wall, colorScale: layer.color_scale, displayMin: layer.display_min, displayMax: layer.display_max, resource_url: h.surface_layer_path(surface, layer) }},
                    images: {image.try!(:name) => [{id: image.try!(:id), corners: self.corners_on_world, path: (image.fits_file? ? image.png_url : image.path), resource_url: h.surface_image_path(surface, image)}]},
    })
  end

  def map(options = {})
    return unless image
    h.content_tag(:div, nil, id: "surface-map", class: options[:class], data:{
                    base_url: Settings.map_url,
                    url_root: "#{Rails.application.config.relative_url_root}/",
                    global_id: surface.global_id,
                    length: surface.length,
                    center: surface.center,
                    add_spot: true,
                    add_radius: true,
                    base_images: surface.base_surface_images.map{ |b_image| {name: b_image.image.name, path: b_image.data.url, width: b_image.image.width, height: b_image.image.height, id: b_image.image.try!(:id), bounds: b_image.bounds} },
                    #layer_groups: [{name: image.try!(:name), opacity: 100, visible:true, displayMin:0, displayMax:25, colorScale:'rainbow' }],
                    layer_groups: surface.wall_surface_layers.reverse.map { |layer| { id: layer.id, name: layer.name, opacity: layer.opacity, tiled: layer.tiled?, bounds: layer.bounds, max_zoom: layer.maxzoom, visible: layer.visible, wall: layer.wall, colorScale: layer.color_scale, displayMin: layer.display_min, displayMax: layer.display_max, resource_url: h.surface_layer_path(surface, layer) }},
                    images: {image.try!(:name) => [{id: image.try!(:id), bounds: image.bounds, max_zoom: original_zoom_level, fits_file: image.fits_file?, corners: self.corners_on_world, path: h.asset_url(image.data.url), resource_url: h.surface_image_path(surface, image) }]},
                    spots: [],
                    bounds: bounds,
                    zoomlabel: []
    })
  end

  def tile_thumbnail(zoom, opts = {})
    if opts[:active]
      ij_center = opts[:active]
    else
      flag_active = false
      center = self.center
      ij_center = surface.tile_at(zoom,center)
     end
     x, y = ij_center
     h.image_tag(tile_path(zoom,x,y), :alt => "#{x}_#{y}")
  end

  def tile_carousel(zoom, opts = {})
    id = "carousel-tile-zoom-#{zoom}"
    h.content_tag(:div, id: id, class: "carousel slide", data:{interval:500}, style:"background-color:#333333;width:256px;height:256px;") do
      h.concat(
        h.content_tag(:div, class: "carousel-inner", role:"listbox") do
          if opts[:active]
            ij_center = opts[:active]
          else
            flag_active = false
            center = self.center
            ij_center = surface.tile_at(zoom,center)
          end
          #[ij_center].each do |x,y|
          tiles_each(zoom) do |x,y|
            h.concat(
                #flag_active = if [x,y] == ij_center
                h.content_tag(:div, class: ([x,y] == ij_center ? "item active" : "item"), data: ([x,y] == ij_center ? {'url' => tile_path(zoom,x,y), 'slide-number' => 0} : {url: tile_path(zoom,x,y)})) do
                #flag_active = false
                #h.concat h.image_tag(nil, :alt => "#{x}_#{y}")
                h.concat h.content_tag(:div, "#{zoom}/#{x}_#{y}", class: "carousel-caption")
              end
            )
          end
        end
      )
      h.concat(
        h.content_tag(:a, class:"left carousel-control", href:"##{id}", role: "button", data:{slide: "prev"}) do
          h.concat h.content_tag(:span, nil, class: "fas fa-chevron-left", 'aria-hidden' => true)
          h.concat h.content_tag(:span, "Previous", class: "sr-only")
        end
      )
      h.concat(
        h.content_tag(:a, class:"right carousel-control", href:"##{id}", role: "button", data:{slide: "next"}) do
          h.concat h.content_tag(:span, nil, class: "fas fa-chevron-right", 'aria-hidden' => true)
          h.concat h.content_tag(:span, "Next", class: "sr-only")
        end
      )
    end
    #h.content_tag(:div, opts)
  end

  def bounds_on_map
    left, upper, right, bottom = image.bounds
    surface.coords_on_map([[left, upper],[right, bottom]])
  end

  def tiles(zoom, &block)
    return unless image
    tiles.each(zoom)
    n = 2**zoom
    path = h.url_for_tile(self) + "#{image.id}/#{zoom}/"
    aa = []
    self.tile_yrange(zoom).each do |y|
      self.tile_xrange(zoom).each do |x|
        yield path + "#{x}_#{y}.png"
      end
    end
  end

  def drop_down_menu
    attachment_file = self.image
    surface = self.surface
    h.content_tag(:div, class: "dropdown") do
      h.concat(
          h.content_tag(:button, class: "btn btn-default btn-xs dropdown-toggle", :title => "dropdown menu for #{attachment_file.name}",  :type => "button", :id => "dropdownMenu1", 'data-toggle' => "dropdown", 'aria-haspopup' => true, 'aria-expanded' => false) do
          h.concat h.truncate(File.basename(attachment_file.name, ".*"), :length => 20)
          h.concat h.content_tag(:span,nil,class:'caret')
        end
      )
      h.concat(
        h.content_tag(:ul, class: "dropdown-menu", 'aria-labelledby' => "dropdownMenu1") do
          h.concat h.content_tag(:li, attachment_file.name, class: "dropdown-header")
          #h.concat h.content_tag(:li, h.link_to("show image", h.attachment_file_path(attachment_file), class: "dropdown-item"))
#          h.concat h.content_tag(:li, h.link_to("type in affine matrix", h.edit_affine_matrix_attachment_file_path(attachment_file, format: :modal), class: "dropdown-item", "data-toggle" => "modal", "data-target" => "#show-modal", title: "#{attachment_file.name}"))
          h.concat h.content_tag(:li, h.link_to("align and export", h.calibrate_svg_surface_image_path(self.surface, attachment_file), class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("align on layer 'Base'", h.calibrate_surface_image_path(self.surface, attachment_file), class: "dropdown-item"))
          h.concat h.content_tag(:li, h.content_tag(:a, "type in affine matrix", href: "#collapseAffine-#{attachment_file.id}", class: "dropdown-item", title: "#{attachment_file.name}", data: {toggle:"collapse"}))
#          h.concat h.content_tag(:li, h.link_to("type in affine matrix", h.edit_attachment_file_path(attachment_file), class: "dropdown-item", title: "#{attachment_file.name}", :target => ["_blank"] ))
          h.concat h.content_tag(:li, h.link_to("type in coordinates of 4 corners", h.edit_corners_attachment_file_path(attachment_file, format: :modal), class: "dropdown-item", "data-toggle" => "modal", "data-target" => "#show-modal", title: "#{attachment_file.name}"))
#          surface.base_surface_images.each do |base_image|
#                   h.concat h.content_tag(:li, h.link_to("calibrate on #{base_image.image.name}", h.calibrate_surface_image_path(self.surface, attachment_file, base_id: base_image.image.id), class: "dropdown-item"))
#          end
          if attachment_file.try!(:affine_matrix).present?
#            h.concat h.content_tag(:li, h.link_to("show on layer 'Base'", h.map_surface_image_path(surface, attachment_file)))
#            h.concat h.content_tag(:li, h.link_to("show tiles", h.zooms_surface_image_path(surface, attachment_file)))
            h.concat h.content_tag(:li, h.link_to("refresh tiles", h.tiles_surface_image_path(surface, attachment_file), method: :post))
          end
          if self.wall
            h.concat h.content_tag(:li, h.link_to("unchoose as 'Base'", h.unchoose_as_base_surface_image_path(surface, attachment_file), method: :post))
          else
            h.concat h.content_tag(:li, h.link_to("choose as 'Base'", h.choose_as_base_surface_image_path(surface, attachment_file), method: :post))
          end
          h.concat h.content_tag(:li, h.link_to("unlink from #{surface.name}", h.surface_image_path(self.surface, attachment_file), method: :delete, data: {confirm: "Are you sure to unlink #{attachment_file.name} from #{surface.name}"}, class: "dropdown-item"))
        end
      )
    end

  end
 

  def drop_down_menu_fits
    attachment_file = self.image
    surface = self.surface
    h.content_tag(:div, class: "dropdown") do
      h.concat(
          h.content_tag(:button, class: "btn btn-default btn-xs dropdown-toggle", :title => "dropdown menu for #{attachment_file.name}",  :type => "button", :id => "dropdownMenu1", 'data-toggle' => "dropdown", 'aria-haspopup' => true, 'aria-expanded' => false) do
          h.concat h.truncate(File.basename(attachment_file.name, ".*"), :length => 20)
          h.concat h.content_tag(:span,nil,class:'caret')
        end
      )
      h.concat(
        h.content_tag(:ul, class: "dropdown-menu", 'aria-labelledby' => "dropdownMenu1") do
          h.concat h.content_tag(:li, attachment_file.name, class: "dropdown-header")
          #h.concat h.content_tag(:li, h.content_tag(:a, "type in affine matrix", href: "#collapseAffine-#{attachment_file.id}", class: "dropdown-item", title: "#{attachment_file.name}", data: {toggle:"collapse"}))
          h.concat h.content_tag(:li, h.link_to("type in coordinates of 4 corners", h.edit_corners_attachment_file_path(attachment_file, format: :modal), class: "dropdown-item", "data-toggle" => "modal", "data-target" => "#show-modal", title: "#{attachment_file.name}"))
          #h.concat h.content_tag(:li, h.link_to("align and export", h.calibrate_svg_surface_image_path(self.surface, attachment_file), class: "dropdown-item"))
          #h.concat h.content_tag(:li, h.link_to("align on layer 'Base'", h.calibrate_surface_image_path(self.surface, attachment_file), class: "dropdown-item"))
          if attachment_file.try!(:affine_matrix).present?
            h.concat h.content_tag(:li, h.link_to("show on layer 'Base'", h.map_surface_image_path(surface, attachment_file)))
          #  h.concat h.content_tag(:li, h.link_to("show tiles", h.zooms_surface_image_path(surface, attachment_file)))
          #  h.concat h.content_tag(:li, h.link_to("refresh tiles", h.tiles_surface_image_path(surface, attachment_file), method: :post))
          end
          h.concat h.content_tag(:li, h.link_to("unlink from #{surface.name}", h.surface_image_path(self.surface, attachment_file), method: :delete, data: {confirm: "Are you sure to unlink #{attachment_file.name} from #{surface.name}"}, class: "dropdown-item"))
        end
      )
    end

  end

  def li_media
    return unless File.exist?(self.image.data.path)
    left = h.content_tag(:a, h.image_tag(self.image.path(:tiny), class:"media-object"), class:"pull-left")
    right = h.content_tag(:div, h.content_tag(:small, self.image.name, class: "media-heading"), class:"media-body")
    h.content_tag(:li, h.raw(left + right), class:"media")
  end

  def li_fits_file(ptokens = [])
    h.content_tag(:li, class: "surface-image", data: {id: self.id, image_id: self.image.id, surface_id: self.surface.id, position: self.position}) do
      h.concat(
        h.content_tag(:div, class:"thumbnail") do
          tokens = self.tokenize
          (tokens - ptokens).each do |token|
            h.concat h.content_tag(:span, token, class:"label label-success")
          end
          h.concat h.content_tag(:span, "Fits", class:"label label-warning")
          unless self.calibrated?
            h.concat h.content_tag(:span, "not calibrated", class:"label label-danger")
          end
          h.concat h.link_to(h.image_tag(self.image.png_url), h.attachment_file_path(self.image)) if File.exist?(self.image.data.path)
          h.concat drop_down_menu_fits
          h.concat h.content_tag(:div, self.image.decorate.matrix_form, class:"collapse", id:"collapseAffine-#{self.image.id}")
        end
      )
      #h.concat self.image.decorate.thumbnail
    end
  end

  def labels(ptokens = [])
    tokens = self.tokenize
    h.content_tag(:div, class:"tokens") do
      (tokens - ptokens).each do |token|
        h.concat h.content_tag(:span, token, class:"label label-success")
      end
    end
  end

  def li_thumbnail(ptokens = [])
    return unless self.image
    return unless self.image.image? || self.image.fits_file?
    h.content_tag(:li, class: "surface-image", id: "surface-image-#{self.id}", data: {id: self.id, image_id: self.image.id, surface_id: self.surface.id, position: self.position}) do
    end
  end

  def thumbnail(ptokens = [])
    return unless self.image
    return unless self.image.image? || self.image.fits_file?
    h.content_tag(:div, class:"thumbnail") do
      tokens = self.tokenize
      (tokens - ptokens).each do |token|
        h.concat h.content_tag(:span, token, class:"label label-success")
      end
      h.concat h.content_tag(:span, "Fits", class:"label label-warning") if self.image.fits_file?
      unless self.calibrated?
        h.concat h.content_tag(:span, "not calibrated", class:"label label-danger")
      end
      if self.image.fits_file?              
        h.concat h.link_to(h.image_tag(self.image.png_url), h.attachment_file_path(self.image)) if File.exist?(self.image.data.path)
      else
        h.concat h.link_to(h.image_tag(self.image.path(:thumb)), h.attachment_file_path(self.image)) if File.exist?(self.image.data.path)
      end
      h.concat drop_down_menu
      h.concat h.content_tag(:div, h.content_tag(:small, self.image.decorate.matrix_form))
    end
  end

  def spots_panel(width: 40, height:40, spots:[], options:{})
    surface = self.surface
    file = self.image
    svg = file.decorate.picture_with_spots(width:width, height:height, spots:spots)
    svg_link = h.link_to(h.surface_image_path(surface, file), title: "show #{self.surface.name}/#{file.name}") do
      svg
    end
    left = h.content_tag(:div, svg_link, class: "col-md-9", :style => "padding:0 0 0 0")
    right = h.content_tag(:div, my_tree(spots), class: "col-md-3", :style => "padding:0 0 0 0")
    row = h.content_tag(:div, left + right, class: "row", :style => "margin-left:0; margin-right:0;")
    header = h.content_tag(:div, class: "panel-heading") do
      h.content_tag(:small, self.image.name)
    end

    body = h.content_tag(:div, row, class: "panel-body", :style => 'padding: 2px')
    contents = []
    contents << header if options[:header]
    contents << body
                         tag = h.content_tag(:div, h.raw(contents.join), class: "panel panel-default surface-image", data: {id: self.id, image_id: self.image.id, surface_id: self.surface.id, position: self.position})
    tag
  end

  def my_tree(spots)
    attachment_file = self.image

    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      #attachment_file.decorate.picture_link
      links = []
      links << h.link_to(h.content_tag(:span, nil, class: "far fa-image"), attachment_file, title: "show #{attachment_file.name}" )
#                         links << h.link_to(h.content_tag(:span, nil, class: "fas fa-cog"), calibrate_surface_image_path(self.surface, attachment_file), title: "calibrate #{attachment_file.name}")
      h.raw(links.join)
    end

    # html += h.content_tag(:div, id: "spots-#{attachment_file.id}", class: "collapse") do
    #   spots_tag = h.raw("")
    #   attachment_file.spots.each do |spot|
    #     spots_tag += h.content_tag(:div, class: html_class, "data-depth" => 2) do
    #       spot.decorate.tree_node(current: false)
    #     end
    #   end
    #   spots_tag
    # end
    html    
  end

  def to_tex
    q_url = "http://dream.misasa.okayama-u.ac.jp/?q="
    basename = File.basename(image.name,".*")
    lines = []
    lines << "\\begin{overpic}[width=0.49\\textwidth]{#{basename}}"
    lines << "\\put(1,74){\\colorbox{white}{(\\sublabel{#{basename}}) \\href{#{q_url}#{image.global_id}}{#{basename}}}}"
    lines << "%%(\\subref{#{basename}}) \\nolinkurl{#{basename}}"
    lines << "\\color{red}"

    surface.surface_images.each do |osurface_image|
      oimage = osurface_image.image
      next unless oimage
      next if oimage.affine_matrix.blank?
      #image_region
      opixels = oimage.spots.map{|spot| [spot.spot_x, spot.spot_y]}
      worlds = oimage.pixel_pairs_on_world(opixels)
      pixels = image.world_pairs_on_pixel(worlds)
      oimage.spots.each_with_index do |spot, idx|
        length = image.length
        height = image.height
        x = "%.1f" % (pixels[idx][0] / length * 100)
        y = "%.1f" % (height.to_f / length * 100 - pixels[idx][1] / length * 100)
        line = "\\put(#{x},#{y})"
        line += "{\\footnotesize \\circle{0.7} \\href{#{q_url}#{spot.target_uid}}{#{spot.name}}}"
        line += " % #{spot.target_uid}" if spot.target_uid
        line += " % \\vs(#{("%.1f" %  worlds[idx][0])}, #{("%.1f" % worlds[idx][1])})"
        lines << line
      end
    end

#    width_on_stage = image.transform_length(image.width / image.length * 100)
    width_on_stage = image.width_on_stage
    if width_on_stage
      scale_length_on_stage = 10 ** (Math::log10(width_on_stage).round - 1)
      scale_length_on_image = image.transform_length(scale_length_on_stage, :world2xy).round
      lines << "%%scale #{("%.0f" % scale_length_on_stage)}\ micro meter"
      lines << "\\put(1,1){\\line(1,0){#{("%.1f" % scale_length_on_image)}}}"
    end

    lines << "\\end{overpic}"

    lines.join("\n")
  end

  def target_path
    surface_image_path(surface, self.image, script_name: Rails.application.config.relative_url_root)
  end
end
