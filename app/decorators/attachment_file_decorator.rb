# -*- coding: utf-8 -*-
class AttachmentFileDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-file") + " #{name} < #{global_id} >"
  end

  def picture(width: 250, height: 250)
    return unless image?
    height_rate = original_height.to_f / height
    width_rate = original_width.to_f / width
    options = (width_rate >= height_rate) ? { width: width } : { height: height }
    h.image_tag(path, options)
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

end
