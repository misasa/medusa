class TableDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def self.icon
      h.content_tag(:span, nil, class: "glyphicon glyphicon-th-list")
  end

  def bib_name_with_id
  	return unless bib
    h.content_tag(:span, nil, class: "glyphicon glyphicon-book") + h.link_to_if(h.can?(:read, bib), " #{bib.name} < #{bib.global_id} >", bib)
  end

  def bib_name
  	return unless bib
    h.content_tag(:span, nil, class: "glyphicon glyphicon-book") + h.link_to_if(h.can?(:read, bib), " #{bib.name}", bib)
  end

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-th-list") + h.raw(" #{caption} < #{h.draggable_id(global_id)} >")
  end

  def publish_badge
    if self.published
      h.published_label(self)
#    else
#      h.link_to(h.content_tag(:button, "publish", type: "button", class: "btn btn-primary"), h.publish_table_path(self.id), method: :put)
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

  def icon
    self.class.icon
  end



  def as_json(options = {})
    super({ methods: [:global_id] }.merge(options))
  end


  def panel(fids = [])
    h.content_tag(:div, class: "panel panel-default") do
      panel_head + panel_body(fids) + panel_foot
    end
  end

  def panel_head
    h.content_tag(:div, class: "panel-heading") do
      h.concat(
        h.content_tag(:span, class: "panel-title pull-left") do
          h.concat(
              h.content_tag(:a, href: "#tableAccordionCollapse-#{self.id}", data: {toggle: "collapse"}, 'aria-expanded' => false, 'aria-control' => "tableAccordionCollapse-#{self.id}", title: "fold table '#{self.caption}'") do
              #h.concat h.content_tag(:span, self.table.data[0].length ,class: "badge")
              h.concat h.content_tag(:span, nil, class: "glyphicon glyphicon-th-list")
              h.concat h.raw(" ")
              h.concat self.caption
              h.concat h.raw(" ") + h.content_tag(:span, nil, class: "glyphicon glyphicon-book")
              #table_link += h.raw(" ")
              h.concat h.raw(" ") + h.link_to_if(h.can?(:read, self.bib), h.raw(self.bib.decorate.author_short_year), self.bib)
            end
          )
        end
      )
      h.concat h.content_tag(:div, nil, class: "clearfix")
    end
  end

  def panel_foot
    h.content_tag(:div, class: "panel-footer") do
      #h.concat h.raw(l.join(" "))
      h.concat h.raw("")
    end
  end

  def panel_body(fids = [])
    l = []
    self.table_specimens.each.with_index(1) do |ts, idx|
      specimen = ts.specimen
      if fids.include?(specimen.id)
        l << h.link_to(h.content_tag(:span, "#{idx};" + specimen.name, class: "badge badge-success"), h.specimen_path(specimen))
      else
        l << h.link_to(h.content_tag(:span, "#{idx};" + specimen.name), h.specimen_path(specimen))
      end
    end
    h.content_tag(:div, class: "panel-body collapse in", id: "tableAccordionCollapse-#{self.id}") do
      h.concat h.content_tag(:div,nil,id:"table_#{self.id}")
      #self.table_specimens.each do |table_specimen|
      #  specimen = table_specimen.specimen
      #  h.concat h.raw("#{specimen.name}")
      #end
      #h.concat h.raw("#{self.method_descriptions.keys.join(', ')}")
      h.concat h.raw(l.join(" "))
    end
  end
  

end
