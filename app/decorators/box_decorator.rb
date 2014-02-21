# -*- coding: utf-8 -*-
class BoxDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + " #{name} < #{global_id} >"
  end
end
