# -*- coding: utf-8 -*-
class AttachmentFileDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def self.icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-file")
  end

  def name_with_id
    tag = h.content_tag(:span, nil, class: "glyphicon glyphicon-file") + h.raw(" #{name} < #{h.draggable_id(global_id)} >")
#    if Settings.rplot_url
#      tag += h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-eye-open"), Settings.rplot_url + '?id=' + global_id, :title => 'plot online')
#    end
    tag
  end

  def icon
    self.class.icon
  end

  def related_pictures
    links = []
    links << h.content_tag(:div, warped_panel(width: 140, height: 120), class: "col-lg-3") if File.exists?(local_path(:warped))
    surfaces.each do |surface|
      links << h.content_tag(:div, surface.decorate.spots_panel(width:140, height: 120), class: "col-lg-3")
    end

    # related_spots.each do |spot|
    #   links << h.content_tag(:div, spot.decorate.spots_panel, class: "col-lg-3")
    # end
    # spot_links.each do |spot|
    #   links << h.content_tag(:div, spot.decorate.spots_panel , class: "col-lg-3")
    # end
    # attachment_image_files.each do |file|
    #   links << h.content_tag(:div, file.decorate.spots_panel(spots: file.spots) , class: "col-lg-3") if file.image?
    # end
    h.content_tag(:div, h.raw( links.join ), class: "row spot-thumbnails")
  end

  def warped_panel(width: 140, height: 120)
    img = picture(width:width, height:height, type: :warped)
    img_link = h.link_to(warped_url) do
      img
    end

    left = h.content_tag(:div, img_link, class: "col-md-12")
    right = h.content_tag(:div, my_tree, class: "col-md-12")
    #row = h.content_tag(:div, left + right, class: "row")
    row = h.content_tag(:div, left, class: "row")
    header = h.content_tag(:div, class: "panel-heading") do
    end

    body = h.content_tag(:div, row, class: "panel-body")
    tag = h.content_tag(:div, body, class: "panel panel-default")
    tag

  end

  def picture_with_spots(width: 250, height: 250, spots: [], with_cross: false)
    return unless image?
    height_rate = original_height.to_f / height
    width_rate = original_width.to_f / width
    scale = (width_rate >= height_rate) ? 1.to_f/width_rate : 1.to_f/height_rate
    length = (original_width >= original_height) ? original_width : original_height
    #options = (width_rate >= height_rate) ? { width: width, height: original_height * scale } : { width: original_width * scale, height: height }
    options = { width: width, height: height}
    svg_options = {xmlns: "http://www.w3.org/2000/svg", 'xmlns:xlink' => "http://www.w3.org/1999/xlink", version: "1.1"}.merge(options)
    image_path = attachment_file.path(:thumb)
    image_tag = %Q|<image xlink:href="#{image_path}" x="0" y="0" width="#{attachment_file.original_width}" height="#{attachment_file.original_height}" data-id="#attachment_file.id}"/>|
    spots.each do |spot|
      spot_options = spot.svg_attributes
      image_tag += spot.decorate.cross_tag(length: length/10) if with_cross
      spot_tag = %Q|<circle #{spot_options.map { |k, v| "#{k}=\"#{v}\"" }.join(" ") }/>|
      image_tag += spot_tag
      #hline_tag = %Q|<circle cx="60" cy="60" r="40" style="fill:skyblue;"/>|
      #hline_tag = %Q|<line x1="0" y1="#{spot.spot_y}" x2="#{original_width}" y2="#{spot.spot_y}" style="stroke:#{spot.stroke_color};stroke-width:#{spot.stroke_width};"/>|
      #vline_tag = %Q|<line x1="#{spot.spot_x}" y1="0" x2="#{spot.spot_x}" y2="#{original_height}" style="stroke:#{spot.stroke_color};stroke-width:#{spot.stroke_width};"/>|
      #path_tag = %Q|<path d="M0,0 100,0 50,100 z" stroke="red" stroke-width="3" fill="none" />|
      #image_tag += hline_tag + vline_tag
    end

    h.content_tag(:svg, h.content_tag(:g, h.raw(image_tag), transform: "scale(#{scale})"), svg_options)
    #h.image_tag(path, options)
  end


  def spots_panel(width: 140, height:120, spots:[])
    file = self
    svg = file.decorate.picture_with_spots(width:width, height:height, spots:spots)
    svg_link = h.link_to(h.attachment_file_path(file)) do
      svg
    end
    #tag = h.content_tag(:div, svg_link, class: "thumbnail")
    left = h.content_tag(:div, svg_link, class: "col-md-12")
    right = h.content_tag(:div, my_tree(spots), class: "col-md-12")
    row = h.content_tag(:div, left + right, class: "row")
    header = h.content_tag(:div, class: "panel-heading") do
      #tag = h.content_tag(:h3, picture_link, class: "panel-title")
      #tag += h.content_tag(:span, h.content_tag(:i, nil, class: "glyphicon glyphicon-chevron-down"), class: "pull-right clickable")
    end

    body = h.content_tag(:div, row, class: "panel-body")
    tag = h.content_tag(:div, body, class: "panel panel-default")
    tag
  end

  def picture(width: 250, height: 250, type: nil)
    return unless image?
    height_rate = original_height.to_f / height
    width_rate = original_width.to_f / width
    options = (width_rate >= height_rate) ? { width: width } : { height: height }
    h.image_tag(path(type), options)
  end

  def my_tree(spots = [])
    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      picture_link
    end

    html += h.content_tag(:div, id: "spots-#{attachment_file.id}", class: "collapse") do
      spots_tag = h.raw("")
      spots.each do |spot|
        spots_tag += h.content_tag(:div, class: html_class, "data-depth" => 2) do
          spot.decorate.tree_node(current: false)
        end
      end
      spots_tag
    end
    html
  end

  def thumbnail
    return unless File.exist?(self.data.path)
    return unless self.image?
    h.content_tag(:div, class:"thumbnail") do
      h.concat h.image_tag(self.path(:thumb))
      h.concat h.content_tag(:small, self.name)
    end
  end

  def picture_link
    picture = h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-picture"), attachment_file)
    attachings.each do |attaching|
      attachable = attaching.attachable
      if attachable
        link = attachable.name
        icon = attachable.decorate.icon
        if h.can?(:read, attachable)
          icon += h.link_to(link, attachable, class: h.specimen_ghost(attachable))
          icon += h.link_to(h.icon_tag('info-sign'), h.polymorphic_path(attachable, script_name: Rails.application.config.relative_url_root, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal")
        else
          icon += link
        end
        picture += icon
      end
    end
    picture += h.icon_tag("screenshot") + h.content_tag(:a, h.content_tag(:span, spots.size, class: "badge"), href:"#spots-#{id}", :"data-toggle" => "collapse") if attachment_file.spots.size > 0
    picture
  end



  def family_tree(current_spot = nil)
    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      picture = h.content_tag(:span, nil, class: "glyphicon glyphicon-picture")
      #picture += 
      surfaces.each do |surface|
        link = surface.name
        icon = surface.decorate.icon
        icon += h.link_to(link, surface)
        picture += icon
      end

      attachings.each do |attaching|
        attachable = attaching.attachable
        if attachable
          link = attachable.name
          icon = attachable.decorate.icon
          if h.can?(:read, attachable)
            icon += h.link_to(link, attachable, class: h.specimen_ghost(attachable)) + h.link_to(h.icon_tag('info-sign'), h.polymorphic_path(attachable, script_name: Rails.application.config.relative_url_root, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal")
          else
            icon += link
          end
          picture += icon
        end
      end
      picture += h.raw (h.icon_tag("screenshot") + "#{spots.size}") if attachment_file.spots.size > 0
      picture
    end

    spots.each do |spot|
      html += h.content_tag(:div, class: html_class, "data-depth" => 2) do
        spot.decorate.tree_node(current: false)
      end
    end
    surface_spots_within_bounds.each do |spot|
      html += h.content_tag(:div, class: html_class, "data-depth" => 3) do
        spot.decorate.tree_node(current: false)
      end
    end

    html
  end

  def thumblink_with_spot_info
    link = h.link_to(h.attachment_file_path(self), class: "thumbnail") do
      im = h.image_tag path
#      im += h.icon_tag("screenshot") + "#{spots.size}" if !spots.empty?
#      im += h.content_tag(:span, nil, class: "glyphicon glyphicon-picture") + " "
      attachings.each do |attaching|
        attachable = attaching.attachable
        im += attachable.decorate.try(:icon) + attachable.name if attachable
      end
      im += h.raw (h.icon_tag("screenshot") + "#{spots.size}") if spots.size > 0
      im
    end
    link
  end

  def tree_node(current: false, current_type: false, in_list_include: false)
    link = current ? h.content_tag(:strong, name) : name
    icon + h.link_to_if(h.can?(:read, self), link, self)
  end

  def specimens_count
    icon_with_count(Specimen, specimens.count)
  end

  def boxes_count
    icon_with_count(Box, boxes.count)
  end

  def analyses_count
    icon_with_count(Analysis, analyses.size)
  end

  def bibs_count
    icon_with_count(Bib, bibs.count)
  end

  def files_count
    icon_with_count(AttachmentFile, attachment_files.count)
  end

  def image_link(width: 40, height: 40)
    content = image? ? decorate.picture(width: width, height: height, type: :thumb) : h.content_tag(:span, nil, class: "glyphicon glyphicon-file")
    h.link_to(content, h.attachment_file_path(self))
  end

  def to_tex
    q_url = "http://dream.misasa.okayama-u.ac.jp/?q="
    basename = File.basename(name,".*")
    lines = []
    lines << "\\begin{overpic}[width=0.49\\textwidth]{#{basename}}"
    lines << "\\put(1,74){\\colorbox{white}{(\\sublabel{#{basename}}) \\href{#{q_url}#{global_id}}{#{basename}}}}"
    lines << "%%(\\subref{#{basename}}) \\href{#{basename}}"
    lines << "\\color{red}"

    surface_spots_within_bounds_converted.each do |spot|
      x = "%.1f" % spot.ref_image_x
      y = "%.1f" % (height.to_f / length * 100 - spot.ref_image_y)

      xy_image = spot.spot_xy_from_center
      xy_world = affine_transform(xy_image[0], xy_image[1])

      line = "\\put(#{x},#{y})"
      line += "{\\footnotesize \\circle{0.7} \\href{#{q_url}#{spot.target_uid}}{#{spot.name}}}"
      line += " % #{spot.target_uid}" if spot.target_uid
      unless affine_matrix.blank?
        line += " % \\vs(#{("%.1f" %  xy_world[0])}, #{("%.1f" % xy_world[1])})"
      end
      lines << line
    end

    unless affine_matrix.blank?
#      width_on_stage = transform_length(width / length.to_f * 100)
      scale_length_on_stage = 10 ** (Math::log10(width_on_stage).round - 1)
      scale_length_on_image = transform_length(scale_length_on_stage, :world2xy).round
      lines << "%%scale #{("%.0f" % scale_length_on_stage)}\ micro meter"
      lines << "\\put(1,1){\\line(1,0){#{("%.1f" % scale_length_on_image)}}}"
    end

    lines << "\\end{overpic}"

    lines.join("\n")
  end


  def matrix_form
    h.form_for(self) do |form|
      h.concat(h.content_tag(:div,nil,id:"affine_editor_#{self.id}"))
      h.concat form.hidden_field :affine_matrix_in_string
      h.concat(form.button(class: "btn btn-default") do
        h.concat h.content_tag(:span, nil, class:"glyphicon glyphicon-save")
      end)
    end
  end

  private

  def icon_with_count(klass, count)
    "#{klass}Decorator".constantize.icon + h.content_tag(:span, count) if count.nonzero?
  end

end
