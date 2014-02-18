# -*- coding: utf-8 -*-
class BibDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + " #{name} < #{global_id} >"
  end
end
