class TableDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-th-list") + " #{description} < #{global_id} >"
  end

end
