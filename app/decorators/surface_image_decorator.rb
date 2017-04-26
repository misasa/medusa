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



  def spots_panel(width: 40, height:40, spots:[])
    surface = self.surface
    file = self.image
    svg = file.decorate.picture_with_spots(width:width, height:height, spots:spots)
    svg_link = h.link_to(h.surface_image_path(surface, file)) do
      svg
    end
    left = h.content_tag(:div, svg_link, class: "col-md-9", :style => "padding:0 0 0 0")
    right = h.content_tag(:div, my_tree(spots), class: "col-md-3", :style => "padding:0 0 0 0")
    row = h.content_tag(:div, left + right, class: "row", :style => "margin-left:0; margin-right:0;")
    header = h.content_tag(:div, class: "panel-heading") do
    end

    body = h.content_tag(:div, row, class: "panel-body", :style => 'padding: 2px')
    tag = h.content_tag(:div, body, class: "panel panel-default")
    tag
  end

  def my_tree(spots)
    attachment_file = self.image

    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      #attachment_file.decorate.picture_link
      h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-picture"), attachment_file)
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

    width_on_stage = image.transform_length(image.width / image.length * 100)
    scale_length_on_stage = 10 ** (Math::log10(width_on_stage).round - 1)
    scale_length_on_image = image.transform_length(scale_length_on_stage, :world2xy).round
    lines << "%%scale #{("%.0f" % scale_length_on_stage)}\ micro meter"
    lines << "\\put(1,1){\\line(1,0){#{("%.1f" % scale_length_on_image)}}}"

    lines << "\\end{overpic}"

    lines.join("\n")
  end

  def target_path
    surface_image_path(surface, self.image, script_name: Rails.application.config.relative_url_root)
  end
end
