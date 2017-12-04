class SurfaceDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-globe")
  end

  # def rplot_url
  #   return unless Settings.rplot_url
  #   Settings.rplot_url + '?id=' + global_id
  # end

  def name_with_id
    tag = h.content_tag(:span, nil, class: "glyphicon glyphicon-globe") + " #{name} < #{global_id} >"
    if false && Settings.rplot_url
      tag += h.link_to("map", rmap_url, :title => 'map online', :target=>["_blank"])
    end
    tag    
  end

    # def rplot_iframe(size = '600')
    #   tag = h.content_tag(:iframe, nil, src: rplot_url, width: size, height: size, frameborder: "no", class: "embed-responsive-item")
    # end

  def to_tex
    surface_images[0].decorate.to_tex unless surface_images.empty?
  end

  def map(options = {})
    left, top, _ = bounds
    len = length
    x_offset = (len - width) / 2
    y_offset = (len - height) / 2
    target_uids = images.inject([]) { |array, image| array + image.spots.map(&:target_uid) }.uniq
    targets = RecordProperty.where(global_id: target_uids).index_by(&:global_id)
    h.content_tag(:div, nil, id: "surface-map", class: options[:class], data: {
                    base_url: Settings.map_url,
                    global_id: global_id,
                    length: len,
                    attachment_files: images.each_with_object({}) { |image, hash| hash[File.basename(image.name, ".*")] = image.id },
                    spots: images.inject([]) { |array, image|
                      array + image.spots.map { |spot|
                        target = targets[spot.target_uid]
                        worlds = spot.spot_world_xy
                        x = (worlds[0] - left + x_offset) * 256 / len
                        y = (top - worlds[1] + y_offset) * 256 / len
                        {
                          id: target.try(:global_id) || spot.global_id,
                          name: target.try(:name) || spot.name,
                          x: x,
                          y: y
                        }
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
        icon += h.link_to(link, specimen)
        picture += icon        
      end
      picture += h.icon_tag("screenshot") + h.content_tag(:a, h.content_tag(:span, spots.size, class: "badge"), href:"#spots-#{id}", :"data-toggle" => "collapse") if surface.spots.size > 0
      picture
    end
    html
  end


  def related_pictures
    links = []
    surface_images.order("position ASC").each do |surface_image|
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
end
