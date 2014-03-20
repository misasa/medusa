# -*- coding: utf-8 -*-
class AnalysisDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-stats") + " #{name} < #{global_id} >"
  end

end
