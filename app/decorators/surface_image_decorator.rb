class SurfaceImageDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers	
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-globe") +
    " " + 
    h.link_to(surface.name, h.surface_path(surface)) + 
    " / #{image.name}"
    #h.raw(" < #{h.draggable_id(surface.global_id)} >")    
  end

  def map(options = {})
    matrix = surface.decorate.affine_matrix_for_map
    return unless matrix
    left, upper, right, bottom = image.bounds
    h.content_tag(:div, nil, id: "surface-map", class: options[:class], data:{
                    base_url: Settings.map_url,
                    url_root: "#{Rails.application.config.relative_url_root}/",
                    global_id: surface.global_id,
                    length: surface.length,
                    matrix: matrix.inv,
                    add_spot: true,
                    add_radius: true,
                    base_image: { id: surface.images.first.try!(:id), name: surface.images.first.try!(:name) },
                    #base_image: {id: image.id, name: image.name, bounds: [] },
                    layer_groups: [],
                    images: {'' => [image.id]},
                    spots: [],
                    bounds: [[left, upper],[right, bottom]].map{|world_x, world_y|
                      x = matrix[0, 0] * world_x + matrix[0, 1] * world_y + matrix[0, 2]
                      y = matrix[1, 0] * world_x + matrix[1, 1] * world_y + matrix[1, 2]
                      [x, y]
                    }
    })
  end
 
  def tile_path(zoom,x,y)
    return unless image
    path = h.url_for_tile(self) + "#{image.id}/#{zoom}/#{x}_#{y}.png"
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
          h.concat h.content_tag(:span, nil, class: "glyphicon glyphicon-chevron-left", 'aria-hidden' => true)
          h.concat h.content_tag(:span, "Previous", class: "sr-only")
        end
      )
      h.concat(
        h.content_tag(:a, class:"right carousel-control", href:"##{id}", role: "button", data:{slide: "next"}) do
          h.concat h.content_tag(:span, nil, class: "glyphicon glyphicon-chevron-right", 'aria-hidden' => true)
          h.concat h.content_tag(:span, "Next", class: "sr-only")
        end
      )
    end
    #h.content_tag(:div, opts)
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
          #h.concat h.content_tag(:li, h.link_to("show #{attachment_file.name}", attachment_file, class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("type in affine matrix", h.edit_attachment_file_path(attachment_file), class: "dropdown-item"))
          h.concat h.content_tag(:li, h.link_to("calibrate", h.calibrate_surface_image_path(self.surface, attachment_file), class: "dropdown-item"))
          if attachment_file.try!(:affine_matrix).present?
            h.concat h.content_tag(:li, h.link_to("show simple map", h.map_surface_image_path(surface, attachment_file)))
            h.concat h.content_tag(:li, h.link_to("show tiles", h.zooms_surface_image_path(surface, attachment_file)))
            h.concat h.content_tag(:li, h.link_to("force create tiles", h.tiles_surface_image_path(surface, attachment_file), method: :post))
          end
          if self.wall
            h.concat h.content_tag(:li, h.link_to("unchoose as base", h.unchoose_as_base_surface_image_path(surface, attachment_file), method: :post))
          else
            h.concat h.content_tag(:li, h.link_to("choose as base", h.choose_as_base_surface_image_path(surface, attachment_file), method: :post))
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

  def li_thumbnail
    return unless self.image
    return unless self.image.image?
    return unless File.exist?(self.image.data.path)
      h.content_tag(:li, class: "surface-image", data: {id: self.id, image_id: self.image.id, surface_id: self.surface.id, position: self.position}) do
        h.concat(
          h.content_tag(:div, class:"thumbnail") do
            h.concat h.image_tag(self.image.path(:thumb))
            #h.concat h.content_tag(:small, self.image.name)
            h.concat drop_down_menu
            if self.wall
              h.concat h.content_tag(:span, "Base", class:"label label-default")
            else
              h.concat h.content_tag(:span, "Overlay", class:"label label-primary")
            end
            #h.concat h.content_tag(:small, self.image.affine_matrix)
          end
        )
        #h.concat self.image.decorate.thumbnail
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
      links << h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-picture"), attachment_file, title: "show #{attachment_file.name}" )
#                         links << h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-cog"), calibrate_surface_image_path(self.surface, attachment_file), title: "calibrate #{attachment_file.name}")
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
