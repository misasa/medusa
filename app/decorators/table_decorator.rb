class TableDecorator < Draper::Decorator
  delegate_all

  def bib_name_with_id
  	return unless bib
    h.content_tag(:span, nil, class: "glyphicon glyphicon-book") + h.link_to_if(h.can?(:read, bib), " #{bib.name} < #{bib.global_id} >", bib)
  end


  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-th-list") + " #{caption} < #{global_id} >"
  end

end
