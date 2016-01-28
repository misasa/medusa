# -*- coding: utf-8 -*-
class AttachmentFileDecorator < Draper::Decorator
  delegate_all
  delegate :as_json
  

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-file") + " #{name} < #{global_id} >"
  end


  def icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-file")
  end

  def picture(width: 250, height: 250, type: nil)
    return unless image?
    height_rate = original_height.to_f / height
    width_rate = original_width.to_f / width
    options = (width_rate >= height_rate) ? { width: width } : { height: height }
    h.image_tag(path(type), options)
  end

  def family_tree(current_spot = nil)
    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      tree_node(true)
    end
    attachings.each do |attaching|
      attachable = attaching.attachable
      if attachable
        spots = self.spots.find_all_by_target_uid(attachable.global_id)
        if spots.empty?
          html += h.content_tag(:div, class: html_class, "data-depth" => 2) do
            h.route_icon(2) + attachable.decorate.tree_node(false)
          end
        else
          spots.each do |spot|
            html += h.content_tag(:div, class: html_class, "data-depth" => 2) do
              h.route_icon(2) + spot.decorate.tree_node(false)
            end
          end
        end
      end
    end
    spots_without_link = self.spots.where("target_uid is null or target_uid = ''")
    spots_without_link.each do |spot|
      html += h.content_tag(:div, class: html_class, "data-depth" => 2) do
        h.route_icon(2) + spot.decorate.tree_node(false)
      end
    end
    html
  end

  def tree_node(current=false)
    link = current ? h.content_tag(:strong, name) : name
    icon = h.content_tag(:span, nil, class: "glyphicon glyphicon-file")
    icon + h.link_to_if(h.can?(:read, self), link, self)
  end

  def specimens_count
    icon_with_count("cloud", specimens.count)
  end

  def boxes_count
    icon_with_count("folder-close", boxes.count)
  end

  def analyses_count
    icon_with_count("stats", analyses.size)
  end

  def bibs_count
    icon_with_count("book", bibs.count)
  end

  def files_count
    icon_with_count("file", attachment_files.count)
  end

  def image_link(width: 40, height: 40)
    content = image? ? decorate.picture(width: width, height: height, type: :thumb) : h.content_tag(:span, nil, class: "glyphicon glyphicon-file")
    h.link_to(content, h.attachment_file_path(self))
  end

  def to_tex
    basename = File.basename(name,".*")
    lines = []
    lines << "\\begin{overpic}[width=0.49\\textwidth]{#{basename}}"
    lines << "\\put(1,74){\\colorbox{white}{(\\sublabel{#{basename}}}) \\url{#{basename}}}}}"
    lines << "%%(\\subref{#{basename}}) \\url{#{basename}}"
    lines << "\\color{red}"

    spots.each do |spot|
      x = "%.1f" % spot.spot_x
      y = "%.1f" % (height.to_f / length * 100 - spot.spot_y)

      xy_image = spot.spot_xy_from_center
      xy_world = affine_transform(xy_image[0], xy_image[1])

      line = "\\put(#{x},#{y})"
      line += "{\\footnotesize \\circle{0.7} \\url{#{spot.name}}}"
      line += " % #{spot.target_uid}" if spot.target_uid
      unless affine_matrix.blank?
        line += " % \\vs(#{("%.1f" %  xy_world[0])}, #{("%.1f" % xy_world[1])})"
      end
      lines << line
    end

    unless affine_matrix.blank?
      width_on_stage = transform_length(width / length * 100)
      scale_length_on_stage = 10 ** (Math::log10(width_on_stage).round - 1)
      scale_length_on_image = transform_length(scale_length_on_stage, :world2xy).round
      lines << "%%scale #{("%.0f" % scale_length_on_stage)}\ micro meter"
      lines << "\\put(1,1){\\line(1,0){#{("%.1f" % scale_length_on_image)}}}"
    end

    lines << "\\end{overpic}"

    lines.join("\n")
  end


  private

  def icon_with_count(icon, count)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}") + h.content_tag(:span, count) if count.nonzero?
  end
end
