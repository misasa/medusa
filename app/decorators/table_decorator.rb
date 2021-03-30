class TableDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def self.icon
      h.content_tag(:span, nil, class: "fas fa-table")
  end

  def bib_name_with_id
  	return unless bib
    h.content_tag(:span, nil, class: "fas fa-book") + h.link_to_if(h.can?(:read, bib), " #{bib.name} < #{bib.global_id} >", bib)
  end

  def bib_name
  	return unless bib
    h.content_tag(:span, nil, class: "fas fa-book") + h.link_to_if(h.can?(:read, bib), " #{bib.name}", bib)
  end

  def name_with_id
    h.content_tag(:span, nil, class: "fas fa-table") + h.raw(" #{caption} < #{h.draggable_id(global_id)} >")
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
     #   table_link += h.link_to(h.content_tag(:span, nil, class: "far fa-eye"), Settings.rplot_url + '?id=' + self.global_id, :title => 'plot online')
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
      panel_head + panel_body(fids) + table_js
    end
  end

  def panel_head
    h.content_tag(:div, class: "panel-heading") do
      h.concat(
        h.content_tag(:span, class: "panel-title pull-left") do
          h.concat(
              h.content_tag(:a, href: "#tableAccordionCollapse-#{self.id}", data: {toggle: "collapse"}, 'aria-expanded' => false, 'aria-control' => "tableAccordionCollapse-#{self.id}", title: "fold or unfold '#{self.caption}'") do
              #h.concat h.content_tag(:span, nil, class: "fas fa-table")
              #h.concat h.raw(" ")
              #h.concat self.caption
              h.concat self.name_with_id
              if self.bib
                h.concat h.raw(" in ") + h.content_tag(:span, nil, class: "fas fa-book")
                h.concat h.raw(" ") + h.link_to_if(h.can?(:read, self.bib), h.raw(self.bib.decorate.author_short_year), self.bib)
              end
              h.concat h.link_to("refreshed at #{h.difference_from_now(self.updated_at)}", h.refresh_table_path(self), title: "refresh '#{self.name}'", class: "small pull-right", method: :put, remote: true)
            end
          )
        end
      )
      h.concat h.content_tag(:div, nil, class: "clearfix")
    end
  end

  def panel_foot
    h.content_tag(:div, class: "panel-footer") do
      h.concat h.link_to(h.content_tag(:span, nil, class:"fas fa-redo"), h.refresh_table_path(self), title: "refresh preview for '#{self.name}'", class: "btn btn-default", method: :put, remote: true)
      h.concat h.raw(" ")
      h.concat h.content_tag(:span, "updated at #{h.difference_from_now(self.updated_at)}")
    end
  end

  def panel_body(fids = [])
    l = []
    self.table_specimens.each.with_index(1) do |ts, idx|
      specimen = ts.specimen
      if fids.include?(specimen.id)
        l << h.content_tag(:span, "#{idx}: " + specimen.name, id:"select_row_#{idx}_in_table_#{self.id}", class: "label label-primary")
      else
        l << h.content_tag(:span, "#{idx}: " + specimen.name, id:"select_row_#{idx}_in_table_#{self.id}", class: "label label-default")
      end
    end
    h.content_tag(:div, class: "panel-body collapse in", id: "tableAccordionCollapse-#{self.id}") do
      h.concat h.content_tag(:div, h.raw(l.join(" ")))
      h.concat h.content_tag(:br, nil)
      h.concat h.content_tag(:div,nil,id:"table_#{self.id}")
      if self.data[:methods]
        self.data[:methods].each do |m|
          h.concat h.content_tag(:div, h.content_tag(:span, h.raw("(#{m[:sign]}) #{m[:description]}")))
        end
      end
      #h.concat h.content_tag(:span, "updated at " + h.difference_from_now(self.updated_at))
    end
  end
  
  def table_js
    m = self.data[:m]
    return unless m
    bs = []
    self.table_specimens.each.with_index(1) do |ts, idx|
      code = <<EOS
      var select_row_#{idx}_in_table_#{self.id} = document.getElementById('select_row_#{idx}_in_table_#{self.id}');
      Handsontable.dom.addEvent(select_row_#{idx}_in_table_#{self.id}, 'click', function () {
        thot_#{self.id}.selectCell(0, #{idx+1});
      });
EOS
      bs << code      
    end

    m[0] = ["",""].concat( self.table_specimens.map.with_index(1){|ts, idx| h.link_to(h.content_tag(:span, "#{idx}", class:"label label-default"), h.specimen_path(ts.specimen), title: "#{ts.specimen.name}") } ) if m
    h.javascript_tag do
      code = <<EOS
      var container = document.getElementById("table_#{self.id}");
      var thot_#{self.id} = new Handsontable(container, {
        data: #{m.to_json},
        columns: [#{ "{ renderer: 'html'}," * m[0].length }],
        licenseKey: 'non-commercial-and-evaluation',
        width: '100%',
        height: #{((m.length + 1) * 25)},
        rowHeights: 25,
        fixedRowsTop: 1,
        fixedColumnsLeft: 2      
        //rowHeaders: true,
        //colHeaders: true
      });
      #{bs.join}
EOS
      h.concat h.raw(code)
    end
  end

end
