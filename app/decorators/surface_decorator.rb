class SurfaceDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-globe")
  end

  def url_for_tile
#    h.root_url + "system/maps/#{global_id}/"
    Settings.map_url + "#{global_id}/"
  end

  def url_for_tiles
    image_ids.map{|image_id| url_for_tile + "#{image_id}/{z}/{x}_{y}.png"}
  end

  def as_json(options = {})
    super({ methods: [:global_id, :image_ids, :globe, :center, :length, :bounds, :url_for_tiles] }.merge(options))
  end
  # def rplot_url
  #   return unless Settings.rplot_url
  #   Settings.rplot_url + '?id=' + global_id
  # end

  def name_with_id
    tag = h.content_tag(:span, nil, class: "glyphicon glyphicon-globe") + h.raw(" #{name} < #{h.draggable_id(global_id)} >")
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

  def map(options = {})
    matrix = affine_matrix_for_map
    return unless matrix
    records = surface_images.includes(:surface_layer, image: :spots)
    images = records.map(&:image)
    target_uids = images.inject([]) { |array, image| array + image.spots.map(&:target_uid) }.uniq
    targets = RecordProperty.where(global_id: target_uids).index_by(&:global_id)
    h.content_tag(:div, nil, id: "surface-map", class: options[:class], data: {
                    base_url: Settings.map_url,
                    url_root: "#{Rails.application.config.relative_url_root}/",
                    global_id: global_id,
                    length: length,
                    matrix: matrix.inv,
                    add_spot: options[:add_spot] || false,
                    base_image: { id: images.first.try!(:id), name: images.first.try!(:name) },
                    layer_groups: surface_layers.map { |layer| { name: layer.name, opacity: layer.opacity } },
                    images: surface_images[1..-1].each_with_object(Hash.new { |h, k| h[k] = [] }) { |surface_image, hash|
                      hash[surface_image.surface_layer.try!(:name)] << surface_image.image_id
                    },
                    spots: images.inject([]) { |array, image|
                      array + image.spots.map { |spot|
                        target = targets[spot.target_uid]
                        worlds = spot.spot_world_xy
                        x = matrix[0, 0] * worlds[0] + matrix[0, 1] * worlds[1] + matrix[0, 2]
                        y = matrix[1, 0] * worlds[0] + matrix[1, 1] * worlds[1] + matrix[1, 2]
                        {
                          id: target.try(:global_id) || spot.global_id,
                          name: target.try(:name) || spot.name,
                          x: x,
                          y: y
                        }
                      }
                    } + direct_spots.map { |spot|
                      target = targets[spot.target_uid]
                      x = matrix[0, 0] * spot.world_x + matrix[0, 1] * spot.world_y + matrix[0, 2]
                      y = matrix[1, 0] * spot.world_x + matrix[1, 1] * spot.world_y + matrix[1, 2]
                      {
                        id: target.try(:global_id) || spot.global_id,
                        name: target.try(:name) || spot.name,
                        x: x,
                        y: y
                      }
                    }
                  })
  end

  def family_tree(current_spot = nil)
    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      picture = h.content_tag(:span, nil, class: "glyphicon glyphicon-globe")
      specimens.each do |specimen|
        next unless specimen
        link = specimen.name
        icon = specimen.decorate.icon
        icon += h.link_to(link, specimen, class: h.specimen_ghost(specimen))
        picture += icon        
      end
      picture += h.icon_tag("screenshot") + h.content_tag(:a, h.content_tag(:span, spots.size, class: "badge"), href:"#spots-#{id}", :"data-toggle" => "collapse") if surface.spots.size > 0
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
      picture = h.content_tag(:span, nil, class: "glyphicon glyphicon-globe")
      picture += h.link_to(surface.name, surface)
      #picture = h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-globe"), self)

      # specimens.each do |specimen|
      #   next unless specimen
      #   link = specimen.name
      #   icon = specimen.decorate.icon
      #   icon += h.link_to(link, specimen)
      #   picture += icon        
      # end
      picture += h.icon_tag("picture") + h.content_tag(:a, h.content_tag(:span, images.size, class: "badge"), href:"#spots-#{id}", :"data-toggle" => "collapse") if images.size > 1
      picture += h.icon_tag("screenshot") + h.content_tag(:a, h.content_tag(:span, spots.size, class: "badge"), href:"#spots-#{id}", :"data-toggle" => "collapse") if surface.spots.size > 0
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
    return if surface_images.blank?
    si = surface_images.first
    return unless si.image
    h.raw(h.url_for_tile(si) + "#{si.image.id}/0/0_0.png")
  end
end
