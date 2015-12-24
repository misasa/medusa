class TableDecorator < Draper::Decorator
  delegate_all

  def bib_name_with_id
  	return unless bib
    h.content_tag(:span, nil, class: "glyphicon glyphicon-book") + " #{bib.name} < #{bib.global_id} >"
  end


  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-th-list") + " #{description} < #{global_id} >"
  end

end
