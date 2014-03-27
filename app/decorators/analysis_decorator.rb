# -*- coding: utf-8 -*-
class AnalysisDecorator < Draper::Decorator
  delegate_all

  def primary_picture(width: 250, height: 250)
    h.image_tag(attachment_files.first.path, width: width, height: height) if attachment_files.present?
  end

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-stats") + " #{name} < #{global_id} >"
  end

end
