class TableDecorator < Draper::Decorator
  delegate_all

  def bib_name_with_id
  	return unless bib
    h.content_tag(:span, nil, class: "glyphicon glyphicon-book") + h.link_to_if(h.can?(:read, bib), " #{bib.name} < #{bib.global_id} >", bib)
  end

  def bib_name
  	return unless bib
    h.content_tag(:span, nil, class: "glyphicon glyphicon-book") + h.link_to_if(h.can?(:read, bib), " #{bib.name}", bib)
  end

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-th-list") + " #{caption} < #{global_id} >"
  end

  def publish_badge
    if self.published
      h.content_tag(:button, "published", type: "button", class: "btn btn-danger")
    else
      h.link_to(h.content_tag(:button, "publish", type: "button", class: "btn btn-primary"), h.publish_table_path(self.id), method: :put)
    end
  end

  def to_link
     table_link = h.link_to(h.raw(self.caption), self )
     # if Settings.rplot_url
     #   table_link += h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-eye-open"), Settings.rplot_url + '?id=' + self.global_id, :title => 'plot online')
     # end
     table_link
  end

  def plot_chemistries
    if Settings.rplot_url
      h.rplot_iframe self
    end
  end
end
