# -*- coding: utf-8 -*-
class SpecimenDecorator < Draper::Decorator
  delegate_all
  delegate :as_json  

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + " #{name} < #{global_id} >"
  end

  def path
    nodes = []
    if box
      nodes += box.ancestors.map { |b| box_node(b) }
      nodes += [box_node(box)]
    end
    nodes += [h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + "me"]
    h.raw(nodes.join("／"))
  end

  def primary_picture(width: 250, height: 250)
    attachment_files.first.decorate.picture(width: width, height: height) if attachment_files.present?
  end

  def family_tree
    h.tree(families.group_by(&:parent_id)) do |obj|
      obj.decorate.tree_node(self == obj)
    end
  end

  def tree_node(current=false)
    link = current ? h.content_tag(:strong, name) : name
    icon = h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud")
    icon + h.link_to_if(h.can?(:read, self), link, self) + children_count + analyses_count + bibs_count + files_count
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

  private

  def box_node(box)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + h.link_to_if(h.can?(:read, box), box.name, box)
  end

  def icon_with_count(icon, count)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}") + h.content_tag(:span, count) if count.nonzero?
  end
end
