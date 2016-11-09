# -*- coding: utf-8 -*-
class SpecimenDecorator < Draper::Decorator
  delegate_all
  delegate :as_json  

  STATUS_NAME = {
    Specimen::Status::NORMAL => "",
    Specimen::Status::UNDETERMINED_QUANTITY => "Undetermined quantity",
    Specimen::Status::DISAPPEARANCE => "Disappearance",
    Specimen::Status::DISPOSAL => "Disposal",
    Specimen::Status::LOSS => "Loss"
  }

  STATUS_ICON_NAME = {
    Specimen::Status::NORMAL => "",
    Specimen::Status::UNDETERMINED_QUANTITY => "question-sign",
    Specimen::Status::DISAPPEARANCE => "fire",
    Specimen::Status::DISPOSAL => "trash",
    Specimen::Status::LOSS => "eye-close"
  }

  def name_with_id(flag_link = false)
    tag = h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud")
    if flag_link
      tag += h.raw(" ") + h.link_to(name, specimen)
    else
      tag += " #{name}"
    end
    tag += " < #{global_id} >"
    tag
  end

  def bibs_with_link
    contents = []
    bibs.each do |bib| 
      content = h.content_tag(:span, nil, class: "glyphicon glyphicon-book")
      content += ""
      content += h.link_to_if(h.can?(:read, bib), h.raw(bib.to_html), bib)
      # if Settings.rplot_url
      #   content += h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-eye-open"), Settings.rplot_url + '?id=' + bib.global_id, :title => 'plot online')
      # end

      #content = h.content_tag(:li, content)
      table_links = []
      bib.tables.each do |table|
         table_link = h.link_to(h.raw(table.caption), table ) if table.specimens && table.specimens.include?(self)
         if table_link &&  Settings.rplot_url
           table_link += h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-eye-open"), Settings.rplot_url + '?id=' + table.global_id, :title => 'plot online')
         end
         table_links << table_link
         #table_links << h.link_to_if(true, h.raw(table.description), table )
      end
      unless table_links.empty?
        content += h.raw " (" + table_links.join(", ") + ")"
      end
      content = h.content_tag(:li, content)
      contents << content
    end
    unless contents.empty?
      h.content_tag(:ul, h.raw(contents.join(" ")) )
    end
  end

  def path_with_id
    path + " < #{global_id} >"
  end

  def path
    nodes = []
    if box
      nodes += box.ancestors.map { |b| box_node(b) }
      nodes += [box_node(box)]
    end
    nodes += [icon + name]
    h.raw(nodes.join("/"))
  end

  def primary_picture(width: 250, height: 250)
    attachment_files.first.decorate.picture(width: width, height: height) if attachment_files.present?
  end

  def list_of_summary_of_analysis
    root = specimen.root
    children = specimen.children
    lis = []
    children.each do |child|
      child = child.decorate
      lis << h.content_tag(:li, child.summary_of_analysis) if child.summary_of_analysis
    end
    children_list = h.content_tag(:ul, h.raw( lis.join) )
    if summary_of_analysis
      content = h.content_tag(:ul, h.content_tag(:li, summary_of_analysis(true)) + children_list )
    end
    unless root == specimen
      content = h.content_tag(:ul, h.content_tag(:li, root.decorate.summary_of_analysis) + content )      
    end
    content
  end

  def summary_of_analysis(current = false)
    analyses = Analysis.where(specimen_id: self_and_descendants)
    return if analyses.count == 0
    item_counts = Chemistry.where(analysis_id: analyses.map(&:id)).group(:measurement_item).size
    measurement_items = MeasurementItem.includes(:unit).all
    specimen_tag = icon + h.link_to_if( h.can?(:read, self), ( current ? h.content_tag(:strong, name, class: "text-primary bg-primary") : name ), self)
    specimen_tag = h.content_tag(:span, specimen_tag, class: "ghost") if specimen.ghost?
    content = specimen_tag
    content += h.content_tag(:span, nil, class: "glyphicon glyphicon-stats")    
    # if Settings.rplot_url
    #   content += h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-eye-open"), Settings.rplot_url + '?id=' + self.global_id, :title => 'plot online')
    # end
    content += h.content_tag(:a, h.content_tag(:span, analyses.size, class: "badge"), href: "#specimen-analyses-#{self.id}", :"data-toggle" => "collapse", class: "collapse-active")

    lis = [] 
    measurement_items.each do |item|
      lis << h.raw(item.display_name) + h.link_to(h.content_tag(:span, item_counts[item], class:"badge"), h.chemistries_specimen_path(self, measurement_item_id: item.id, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal" ) if item_counts[item]
# + h.link_to(h.icon_tag('info-sign'), h.polymorphic_path(attachable, script_name: Rails.application.config.relative_url_root, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal", class: h.specimen_ghost(attachable))
    end
    #content += h.content_tag(:div, h.raw(lis.join), id: "specimen-analyses-#{self.id}", class: ( current ? "collapse in" : "collapse" ) )
    content += h.content_tag(:div, h.raw(lis.join), id: "specimen-analyses-#{self.id}", class: "collapse" )
    content
  end

  def plot_chemistries
    #h.high_chart("plot-summary", generate_summary_plot)
    if Settings.rplot_url
      h.rplot_iframe self
    else
      plot_histograms
    end
  end

  def plot_histograms
    tag = ""
    pls = []
    generate_plots.each_with_index do |graph, id|
      pls << h.raw(h.content_tag(:div, h.high_chart("plot-#{id}", graph), class: 'col-lg-4'))
    end
    tag += h.content_tag(:div, h.raw(pls.join), class: 'row spot-thumbnails')
    h.raw(tag)
  end

  def generate_chart_globals
    chart_globals = LazyHighCharts::HighChartGlobals.new do |f|
      f.global(useUTC: false)
      f.chart(
        backgroundColor: {
          linearGradient: [0, 0, 500, 500],
          stops: [
            [0, "rgb(255, 255, 255)"],
            [1, "rgb(240, 240, 255)"]
          ]
        },
        borderWidth: 2,
        plotBackgroundColor: "rgba(255, 255, 255, .9)",
        plotShadow: true,
        plotBorderWidth: 1
      )
      f.lang(thousandsSep: ",")
      f.colors(["#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354"])
    end
  end

  def generate_summary_plot

    analyses = Analysis.where(specimen_id: self_and_descendants)
    return if analyses.count == 0
    all_chemistries = Chemistry.where(analysis_id: analyses.map(&:id))
    measurement_item_ids = all_chemistries.pluck(:measurement_item_id).uniq
    measurement_items = MeasurementItem.find(measurement_item_ids)
    ms = {}
    measurement_items.each_with_index do |measurement_item, index|
      chemistries = all_chemistries.with_unit.search_with_measurement_item_id(measurement_item.id)
      values = chemistries.select_value_in_parts.map(&:value_in_parts)
      #ms[measurement_item.nickname] = values.compact.map{|v| [v, index]}
      ms[measurement_item.display_in_html] = values.map{|v| [v, index] if v != 0.0}.compact
      # (bins, freqs) = values.histogram(5)
      # summary = chemistries.select_summary_value_in_parts[0]

      # count = summary.count
      # min = summary.min
      # max = summary.max
      # avg = summary.avg
    end
    #p ms
    #ms = {'SiO2' => [0.562, 0.553, 0.512, 0.32].map{|v| [v, 1]}, 'Al2O3' => [0.00123,0.00225,0.00312].map{|v| [v,2]}}
    #ms = {'SiO2' => [[0.562,1], [0.553,1], [0.512,1], [0.32,1]], 'Al2O3' => [[0.123,2],[0.225,2],[0.312,2]]}
    #p ms
    chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart(type: 'scatter', zoomType: 'xy')
      f.title(text: 'Height Versus Weight of 507 Individuals by Gender')
      f.subtitle(text: 'Source: Heinz 2003')
      f.xAxis(title: {enabled: true,text: 'Value (parts)'},startOnTick: true,endOnTick: true,showLastLabel: true,type: 'logarithmic')
      f.yAxis(title: {text: 'Measurement Item'}, labels: {enabled: false})
      f.legend(enabled: false)
      f.plotOptions(
            scatter: {
                marker: {
                    radius: 5,
                    states: {
                        hover: {
                            enabled: true,
                            lineColor: 'rgb(100,100,100)'
                        }
                    }
                },
                states: {
                    hover: {
                        marker: {
                            enabled: false
                        }
                    }
                },
                tooltip: {
                    headerFormat: '<b>{series.name}</b><br>',
                    pointFormat: '{point.x}'
                }
            }
        )
      ms.each do |key, value|
        f.series(name: key, data: value)
      end
      # f.series(
      #         name: 'Female',
      #         #color: 'rgba(223, 83, 83, .5)',
      #         data: [[161.2, 1], [167.5, 1], [159.5, 1], [15700.0, 1], [0.155, 1]]
      # )

      # f.series(
      #         name: 'Male',
      #         #color: 'rgba(119, 152, 191, .5)',
      #         data: [[174.0, 2], [175.3, 2], [193.5, 2], [186.5, 2], [187.2, 2]]
      # )


      # f.series(name: 'Temperatures',data: [
      #           [-9.7, 9.4],
      #           [-8.7, 6.5],
      #           [-3.5, 9.4],
      #           [-1.4, 19.9],
      #           [0.0, 22.6],
      #           [2.9, 29.5],
      #           [9.2, 30.7],
      #           [7.3, 26.5],
      #           [4.4, 18.0],
      #           [-3.1, 11.4],
      #           [-5.2, 10.4],
      #           [-13.5, 9.8]
      #       ]
      # )
    end
    chart
  end

  def generate_plots
    analyses = Analysis.where(specimen_id: self_and_descendants)
    graphs = []
    return graphs if analyses.count == 0
    all_chemistries = Chemistry.where(analysis_id: analyses.map(&:id))
#    all_chemistries = Chemistry.all
    measurement_item_ids = all_chemistries.pluck(:measurement_item_id).uniq
    measurement_items = MeasurementItem.find(measurement_item_ids)
    measurement_items.each_with_index do |measurement_item, index|
    #Chemistry.where(analysis_id: analyses.map(&:id)).group_by{|g| g.measurement_item_id}.each do |measurement_item_id, chemistries|
      #measurement_item = MeasurementItem.find(measurement_item_id)
      chemistries = all_chemistries.with_unit.search_with_measurement_item_id(measurement_item.id)
      values = chemistries.select_value_in_parts.map(&:value_in_parts)
      #chemistries = Chemistry.where(analysis_id: analyses.map(&:id), measurement_item_id: measurement_item.id).order(:value)
      (bins, freqs) = values.histogram(5)
      summary = chemistries.select_summary_value_in_parts[0]

      count = summary.count
      min = summary.min
      max = summary.max
      avg = summary.avg
      graph = LazyHighCharts::HighChart.new('graph') do |f|
        f.chart(borderWidth: 1)
        f.title(text: sprintf("%s %.3f (n=%d)", measurement_item.display_in_html, avg, count))        
        #f.subtitle(text: sprintf("average %.3f (%d)", avg, count), verticalAlign: 'middle')
        f.xAxis(categories: bins.map{|n| sprintf("%.3f", n)})
        f.series(name:  measurement_item.display_in_html, data: freqs, type: 'column')
        f.legend(enabled: false)
      end
      graphs << graph
    end
    graphs
  end

  def generate_chart_quantity_history
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: 'Specimen quantity history graph')
      f.xAxis(type: 'datetime')
      f.yAxis(min: 0, title: { text: "quantity(g)" })
      f.chart(height: 600)
      f.series(name: "total", data: quantity_history[0], type: 'line', step: 'left')
      quantity_history.each do |key, data|
        specimen = Specimen.find_by(id: key)
        if specimen
          f.series(name: specimen.name, data: data, type: 'line', step: 'left')
        end
      end
    end
  end

  def family_tree
    # list = [self].concat(children)
    # #list = [root].concat(root.children)
    # ans = ancestors
    # depth = ans.size
    # if depth > 0
    #   list.concat(siblings)
    #   list.concat(ans)
    #   ans.each do |an|
    #     list.concat(an.siblings)
    #   end
    # # elsif depth > 1
    # #   list.concat(ans[1].descendants)
    # end
    # list.uniq!
    # relatives = families.select{|e| list.include?(e) }
#    h.tree(relatives_for_tree.group_by(&:parent_id)) do |obj|
    in_list = [object].concat(ancestors)
    h.tree(families.group_by(&:parent_id), type_name: "specimen", in_list: in_list) do |obj|
      obj.decorate.tree_node(current: object == obj, current_type: (object.class == obj.class), in_list_include: in_list.include?(obj))
    end
  end

  def tree_node(current: false, current_type: false, in_list_include: false)
    link = current ? h.content_tag(:strong, name, class: "text-primary bg-primary") : name
    html = icon + h.link_to_if(h.can?(:read, self), link, self)
    html += children_count(current_type, in_list_include)
    html += analyses_count
    html += bibs_count
    html += files_count
    html
  end

  def children_count(current_type=false, in_list_include=false)
    if current_type
      icon_with_badge_count("cloud", children.size, in_list_include)
    else
      icon_with_count("cloud", children.size)
    end
  end

  def analyses_count
    icon_with_count("stats", analyses.count)
  end

  def bibs_count
    icon_with_count("book", bibs.count)
  end

  def files_count
    icon_with_count("file", attachment_files.count)
  end

  def related_pictures
    links = []
    related_spots.each do |spot|
#      links << h.content_tag(:div, h.content_tag(:div, spot.decorate.thumblink_with_spot_info, class: "panel-body"), class: "panel panel-default col-lg-4")
#      links << h.content_tag(:div, spot.decorate.thumblink_with_spot_info, class: "col-lg-3")
      links << h.content_tag(:div, spot.decorate.spots_panel, class: "col-lg-3")
#      links << h.content_tag(:div, spot.attachment_file.decorate.picture_with_spots(width:100, height:100, :spots => [spot]) , class: "col-lg-2")
    end
    spot_links.each do |spot|
      links << h.content_tag(:div, spot.decorate.spots_panel , class: "col-lg-3")
#      links << h.content_tag(:div, spot.attachment_file.decorate.picture_with_spots(width:100, height:100, :spots => [spot]) , class: "col-lg-2")
    end
    attachment_image_files.each do |file|
      links << h.content_tag(:div, file.decorate.spots_panel(spots: file.spots) , class: "col-lg-3") if file.image?
    end
    h.content_tag(:div, h.raw( links.join ), class: "row spot-thumbnails")
  end

  def to_tex(alias_specimen)
    lines = []
    lines << '%------------'
    lines << 'The sample names, physical forms, quantities and ID of each daughters are listed in Table \\ref{daughters}.' 
    lines << '%------------'
    lines << '\begin{footnotesize}'
    lines << '\begin{table}'
    lines << "\\caption{Daughter #{alias_specimen.pluralize} of #{name} (#{global_id}) as of #{Time.now.to_date}.}"
    lines << '\begin{center}'
    lines << '\begin{tabular}{lll}'
    lines << '\hline'
    lines << ["#{alias_specimen} name", "physical form", "quantity", "ID", "remark"].join("\t&\t") + "\\\\"
    lines << '\hline'
    children.each do |specimen|
      lines << [specimen.name, specimen.physical_form.try!(:name), specimen.try!(:quantity), specimen.global_id].join("\t&\t") + "\\\\"
    end
    lines << '\hline'
    lines << '\end{tabular}'
    lines << '\end{center}'
    lines << '\label{daughters}'
    lines << '\end{table}'
    lines << '\end{footnotesize}'
    lines << '%------------'
    return lines.join("\n")
  end

  def icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + status_icon
  end

  def status_name
    STATUS_NAME[status]
  end

  def status_icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-#{STATUS_ICON_NAME[status]}")
  end

  def status_name
    STATUS_NAME[status]
  end

  def status_icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-#{STATUS_ICON_NAME[status]}")
  end

  private

  def box_node(box)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + h.link_to_if(h.can?(:read, box), box.name, box)
  end


  def icon_with_count(icon, count)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}") + h.content_tag(:span, count) if count.nonzero?
  end

  def icon_with_badge_count(icon, count, in_list_include=false)
    if count > 0
      badge = h.content_tag(:span, count, class: (in_list_include ? "badge badge-active" : "badge"))
      html = h.content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}")
      html += h.content_tag(:a, badge, href: "#tree-#{id}", :"data-toggle" => "collapse", class: "collapse-active")
    end
  end
end
