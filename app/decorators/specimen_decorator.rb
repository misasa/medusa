# -*- coding: utf-8 -*-
class SpecimenDecorator < Draper::Decorator
  delegate_all
  delegate :as_json  

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
      content = h.content_tag(:span, nil, class: "glyphicon glyphicon-book") + "" + h.link_to_if(h.can?(:read, bib), h.raw(bib.to_html), bib)
      #content = h.content_tag(:li, content)
      table_links = []
      bib.tables.each do |table|
         table_links << h.link_to(h.raw(table.caption), table ) if table.specimens && table.specimens.include?(self)
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
    nodes += [h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + name]
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
    content += h.content_tag(:span, nil, class: "glyphicon glyphicon-stats") + h.content_tag(:a, h.content_tag(:span, analyses.size, class: "badge"), href: "#specimen-analyses-#{self.id}", :"data-toggle" => "collapse" )
    lis = [] 
    measurement_items.each do |item|
      lis << h.raw(item.display_name) + h.content_tag(:span, item_counts[item], class:"badge") if item_counts[item]
    end
    #content += h.content_tag(:div, h.raw(lis.join), id: "specimen-analyses-#{self.id}", class: ( current ? "collapse in" : "collapse" ) )
    content += h.content_tag(:div, h.raw(lis.join), id: "specimen-analyses-#{self.id}", class: "collapse" )
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
    h.tree(families.group_by(&:parent_id), nil, 1, [self].concat(ancestors)) do |obj|
      obj.decorate.tree_node(self == obj)
    end
  end

  def tree_node(current=false)
    link = current ? h.content_tag(:strong, name, class: "text-primary bg-primary") : name
    icon = h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud")
    html = icon + h.link_to_if(h.can?(:read, self), link, self)
    html += h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + h.content_tag(:a, h.content_tag(:span, children.size, class: "badge"), href: "#tree-#{self.id}", :"data-toggle" => "collapse" ) if children.size > 0
    html += analyses_count
    html += bibs_count
    html += files_count
    html
  end

  def children_count
    icon_with_count("cloud", children.count)
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
      links << h.content_tag(:div, spot.decorate.spots_panel, class: "col-lg-4")
#      links << h.content_tag(:div, spot.attachment_file.decorate.picture_with_spots(width:100, height:100, :spots => [spot]) , class: "col-lg-2")
    end
    spot_links.each do |spot|
      links << h.content_tag(:div, spot.decorate.spots_panel , class: "col-lg-4")
#      links << h.content_tag(:div, spot.attachment_file.decorate.picture_with_spots(width:100, height:100, :spots => [spot]) , class: "col-lg-2")
    end
    attachment_image_files.each do |file|
      links << h.content_tag(:div, file.decorate.spots_panel(spots: file.spots) , class: "col-lg-4") if file.image?
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
    h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud")
  end

  private

  def box_node(box)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + h.link_to_if(h.can?(:read, box), box.name, box)
  end


  def icon_with_count(icon, count)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}") + h.content_tag(:span, count) if count.nonzero?
  end
end
