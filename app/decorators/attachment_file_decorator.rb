# -*- coding: utf-8 -*-
class AttachmentFileDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + " #{name} < #{global_id} >"
  end

  def original_width
    return "" if original_geometry.blank?
    original_geometry.split("x")[0].to_i
  end

  def original_height
    return "" if original_geometry.blank?
    original_geometry.split("x")[1].to_i
  end

end
