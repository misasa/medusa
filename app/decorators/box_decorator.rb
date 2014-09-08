# -*- coding: utf-8 -*-
class BoxDecorator < Draper::Decorator
  delegate_all
  delegate :to_json
  
  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + " #{name} < #{global_id} >"
  end

  def primary_picture(width: 250, height: 250)
    attachment_files.first.decorate.picture(width: width, height: height) if attachment_files.present?
  end

  def family_tree
    h.tree(current_box_hash(children), parent_id) do |obj|
      obj.decorate.tree_node(self == obj)
    end
  end

  def current_box_hash(children)
    box_hash = children.group_by(&:parent_id)
    box_hash[parent_id] = [object]
    box_hash
  end

  def tree_node(current=false)
    link = current ? h.content_tag(:strong, name) : name
    icon = h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close")
    icon + h.link_to_if(h.can?(:read, self), link, self) + stones_count + boxes_count + analyses_count + bibs_count + files_count
  end

  def stones_count
    icon_with_count("cloud", stones.count)
  end

  def boxes_count
    icon_with_count("folder-close", children.count)
  end

  def analyses_count
    icon_with_count("stats", stones.inject(0) {|count, stone| count += stone.analyses.size })
  end

  def bibs_count
    icon_with_count("book", bibs.count)
  end

  def files_count
    icon_with_count("file", attachment_files.count)
  end

  def boxed_stones
    Stone.includes(:record_property, :user, :group, :physical_form).where(box_id: self.id)
  end

  def boxed_boxes
    Box.includes(:record_property, :user, :group).where(parent_id: self.id)
  end

  def to_tex
    lines = []
    lines << '%------------'
    lines << 'The sample names and ID of each mounted materials are listed in Table \\ref{mount:materials}.'
    lines << '%------------'
    lines << '\begin{footnotesize}'
    lines << '\begin{table}'
    lines << "\\caption{Stones mounted on #{name} (#{global_id}) as of #{Time.now.to_date}.}"
    lines << '\begin{center}'
    lines << '\begin{tabular}{lll}'
    lines << '\hline'
    lines << ["stone name", "ID", "remark"].join("\t&\t") + "\\\\"
    lines << '\hline'
    stones.each do |stone|
      lines << [stone.name, stone.global_id, ""].join("\t&\t") + "\\\\"
    end
    lines << '\hline'
    lines << '\end{tabular}'
    lines << '\end{center}'
    lines << '\label{mount:materials}'
    lines << '\end{table}'
    lines << '\end{footnotesize}'
    lines << '%------------'
    return lines.join("\n")
  end

  def box_path
    nodes = []
    if box
      nodes += box.ancestors.map { |b| box_node(b) }
    end
    nodes += [h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + "me"]
    h.raw(nodes.join("／"))
  end

  def analysis_name
    object.stones.map{|stone| stone.analyses.pluck(:name)}.join(", ")
  end

  private

  def box_node(box)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + h.link_to_if(h.can?(:read, box), box.name, box)
  end

  def icon_with_count(icon, count)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}") + h.content_tag(:span, count) if count.nonzero?
  end

end
