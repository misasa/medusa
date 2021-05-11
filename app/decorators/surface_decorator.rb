class SurfaceDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def icon
    h.content_tag(:span, nil, class: "fas fa-globe-asia")
  end

  def maps_url
    Settings.map_url.blank? ? "#{Rails.application.config.relative_url_root}/system/maps/" : Settings.map_url
  end

  def url_for_tile
#    h.root_url + "system/maps/#{global_id}/"
    maps_url + "#{global_id}/"
  end

  def url_for_tiles
    image_ids.map{|image_id| url_for_tile + "#{image_id}/{z}/{x}_{y}.png"}
  end

  def as_json(options = {})
    super({ methods: [:global_id, :image_ids, :layers, :globe, :center, :length, :url_for_tiles, :map_data] }.merge(options))
  end

  def layers
    surface_layers.pluck(:id, :name)
  end
    # def rplot_url
  #   return unless Settings.rplot_url
  #   Settings.rplot_url + '?id=' + global_id
  # end

  def icon_with_name
    tag = h.content_tag(:span, nil, class: "fas fa-globe-asia") + h.raw(" #{name}")
  end

  def name_with_id
    tag = h.content_tag(:span, nil, class: "fas fa-globe-asia") + h.raw(" #{name} < #{h.draggable_id(global_id)} >")
    if false && Settings.rplot_url
      tag += h.link_to("map", rmap_url, :title => 'map online', :target=>["_blank"])
    end
    tag    
  end

  def link_with_id
    tag = h.content_tag(:span, nil, class: "fas fa-globe-asia") + h.raw(" ") + h.link_to(name, h.surface_path(self)) + h.raw(" < #{h.draggable_id(global_id)} >")
    if false && Settings.rplot_url
      tag += h.link_to("map", rmap_url, :title => 'map online', :target=>["_blank"])
    end
    tag
  end

    # def rplot_iframe(size = '600')
    #   tag = h.content_tag(:iframe, nil, src: rplot_url, width: size, height: size, frameborder: "no", class: "embed-responsive-item")
    # end

  def to_tex
    return unless surface_images[0]
    return unless surface_images[0].image
    surface_images[0].decorate.to_tex unless surface_images.empty?
  end

  def bounds_on_map(image)
    left, upper, right, bottom = image.bounds
    [[left, upper], [right, bottom]].map{|world_x, world_y|
      x = matrix[0, 0] * world_x + matrix[0, 1] * world_y + matrix[0, 2]
      y = matrix[1, 0] * world_x + matrix[1, 1] * world_y + matrix[1, 2]
      [x, y]
    }
  end

  def center_str
    x,y = self.center
    sprintf("[%.3f,%.3f]", x, y)
  end

  def length_str
    sprintf("%.3f", self.length)
  end

  def map_data(options = {})
    surface_length = self.length
    tilesize = self.tilesize
    s_images = surface_images.calibrated.reverse
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
    {
      base_url: maps_url,
      resource_url: h.surface_path(surface),
      url_root: "#{Rails.application.config.relative_url_root}/",
      global_id: global_id,
      length: length,
      center: center,
      base_images: base_images,
      layer_groups: surface_layers.reverse.map { |layer| { id: layer.id, name: layer.name, opacity: layer.opacity, tiled: layer.tiled?, bounds: layer.bounds, max_zoom: layer.maxzoom, visible: layer.visible, wall: layer.wall, colorScale: layer.color_scale, displayMin: layer.display_min, displayMax: layer.display_max, resource_url: h.surface_layer_path(surface, layer) }},
      images: h_images,
    }
  end


  def map(options = {})
    if self.globe?
      lat = 0
      lng = 0
      zoom = 2
      specimens = options[:specimens]
      if !specimens.empty?
        place = specimens[0].place
        lat = place.latitude
        lng = place.longitude
      end
      ActsAsMappable::Mappable::HtmlGenerator.generate(lat: lat, lng: lng, zoom: zoom, width: '100%', height: 900)
    else
      h.content_tag(:div, nil, id: "surface-map", class: options[:class], data: map_data)
    end
  end


  def family_tree(current_spot = nil)
    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      picture = h.content_tag(:span, nil, class: "fas fa-globe-asia")
      specimens.each do |specimen|
        next unless specimen
        link = specimen.name
        icon = specimen.decorate.icon
        icon += h.link_to(link, specimen, class: h.specimen_ghost(specimen))
        picture += icon        
      end
      picture += h.icon_tag("crosshairs") + h.content_tag(:a, h.content_tag(:span, spots.size, class: "badge"), href:"#spots-#{id}", :"data-toggle" => "collapse") if surface.spots.size > 0
      picture
    end
    html
  end


  def related_pictures
    links = []
    surface_images.reorder("position DESC").each do |surface_image|
      file = surface_image.image
      next unless file
      links << h.content_tag(:div, surface_image.decorate.spots_panel(spots: file.spots) , class: "col-lg-2", :style => "padding:0 0 0 0" ) if file.image?
    end
    h.content_tag(:div, h.raw( links.join ), class: "row spot-thumbnails", :style => "margin-left:0; margin-right:0;")
  end

  def spots_panel(width: 140, height:120, spots:[])
    surface = self
    file = self.first_image
    svg = file.decorate.picture_with_spots(width:width, height:height, spots:spots)
    svg_link = h.link_to(h.surface_image_path(surface, file)) do
      svg
    end
    left = h.content_tag(:div, svg_link, class: "col-md-12")
    right = h.content_tag(:div, my_tree, class: "col-md-12")
    row = h.content_tag(:div, left + right, class: "row")
    header = h.content_tag(:div, class: "panel-heading") do
    end

    body = h.content_tag(:div, row, class: "panel-body")
    tag = h.content_tag(:div, body, class: "panel panel-default")
    tag
  end

  def my_tree
    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      picture = h.content_tag(:span, nil, class: "fas fa-globe-asia")
      picture += h.link_to(surface.name, surface)
      #picture = h.link_to(h.content_tag(:span, nil, class: "fas fa-globe-asia"), self)

      # specimens.each do |specimen|
      #   next unless specimen
      #   link = specimen.name
      #   icon = specimen.decorate.icon
      #   icon += h.link_to(link, specimen)
      #   picture += icon        
      # end
      picture += h.icon_tag("image") + h.content_tag(:a, h.content_tag(:span, images.size, class: "badge"), href:"#spots-#{id}", :"data-toggle" => "collapse") if images.size > 1
      picture += h.icon_tag("crosshairs") + h.content_tag(:a, h.content_tag(:span, spots.size, class: "badge"), href:"#spots-#{id}", :"data-toggle" => "collapse") if surface.spots.size > 0
      picture
    end

    html
  end
  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def images_count
    images.count unless globe?
  end

  def spots_count
    globe ? Place.count : images.sum { |image| image.spots.count }
  end

  def base_image_url
    return unless appearance
    return h.raw(h.url_for_tile(appearance))
  end
end
