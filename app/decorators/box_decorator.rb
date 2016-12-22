# -*- coding: utf-8 -*-
class BoxDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def self.icon(in_list_include=false)
    h.content_tag(:span, nil, class: in_list_include ? "glyphicon glyphicon-folder-open" : "glyphicon glyphicon-folder-close")
  end

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + " #{name} < #{global_id} >"
  end

  def box_path_with_id(link_flag = false)
    box_path + " < #{global_id} >"
  end

  def primary_picture(width: 250, height: 250)
    attachment_files.first.decorate.picture(width: width, height: height) if attachment_files.present?
  end

  def family_tree
    in_list = [object, object.parent]
    classes = [Box, Specimen]
    h.tree(current_box_hash, classes: classes, key: parent.try(:record_property_id), in_list: in_list) do |obj|
      obj.decorate.tree_node(current: (self == obj), current_type: (object.class == obj.class), in_list_include: in_list.include?(obj))
    end
  end

  def current_box_hash
    hash = Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = Array.new } }
    hash[object.parent.try(:record_property_id)][Box] = [object]
    hash[object.record_property_id][Box] = object.children
    hash[object.record_property_id][Specimen] = object.specimens
    hash[object.record_property_id][Bib] = object.bibs
    hash[object.record_property_id][AttachmentFile] = object.attachment_files
    children.each do |box|
      hash[box.record_property_id][Box] = []
      hash[box.record_property_id][Specimen] = []
      hash[box.record_property_id][Bib] = []
      hash[box.record_property_id][AttachmentFile] = []
    end
    object.specimens.each do |specimen|
      hash[specimen.record_property_id][Analysis] = []
      hash[specimen.record_property_id][Bib] = []
      hash[specimen.record_property_id][AttachmentFile] = []
    end
    hash
  end

  def tree_nodes(klass, depth)
    hash = Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = Array.new } }
    objects = []
    if klass == Box
      objects = children
      objects.each do |box|
        hash[box.record_property_id][Box] = []
        hash[box.record_property_id][Specimen] = []
        hash[box.record_property_id][Bib] = []
        hash[box.record_property_id][AttachmentFile] = []
      end
    elsif klass == Specimen
      objects = specimens
      objects.each do |specimen|
        hash[specimen.record_property_id][Analysis] = []
        hash[specimen.record_property_id][Bib] = []
        hash[specimen.record_property_id][AttachmentFile] = []
      end
    elsif klass == Bib
      objects = bibs
    elsif klass == AttachmentFile
      objects = attachment_files
    else
      return ""
    end
    hash[record_property_id][klass] = objects
    in_list = [object]
    classes = [Box, Specimen]
    h.tree(hash, classes: classes, key: record_property_id, in_list: in_list, depth: depth) do |obj|
      obj.decorate.tree_node(current_type: (object.class == obj.class))
    end
  end

  def tree_node(current: false, current_type: false, in_list_include: false)
    link = current ? h.content_tag(:strong, name, class: "text-primary bg-primary") : name
    html = icon(in_list_include) + h.link_to_if(h.can?(:read, self), link, self)
    html += boxes_count(current_type, in_list_include)
    html += specimens_count(current_type, in_list_include)
    html += bibs_count(current_type, in_list_include)
    html += files_count(current_type, in_list_include)
    html
  end

  def specimens_count(current_type=false, in_list_include=false)
    if current_type
      icon_with_badge_count(Specimen, specimens.count, in_list_include)
    else
      icon_with_count(Specimen, specimens.count)
    end
  end

  def boxes_count(current_type=false, in_list_include=false)
    if current_type
      icon_with_badge_count(Box, children.size, in_list_include)
    else
      icon_with_count(Box, children.count)
    end
  end

  def analyses_count
    icon_with_count(Analysis, specimens.inject(0) {|count, specimen| count += specimen.analyses.size })
  end

  def bibs_with_link
    contents = []
    bibs.each do |bib| 
      content = h.content_tag(:span, nil, class: "glyphicon glyphicon-book") + "" + h.link_to_if(h.can?(:read, bib), h.raw(bib.to_html), bib)
      content = h.content_tag(:li, content)
      contents << content
    end
    unless contents.empty?
      h.content_tag(:ul, h.raw(contents.join(" ")) )
    end
  end

  def bibs_count(current_type=false, in_list_include=false)
    if current_type
      icon_with_badge_count(Bib, bibs.count, in_list_include)
    else
      icon_with_count(Bib, bibs.count)
    end
  end

  def files_count(current_type=false, in_list_include=false)
    if current_type
      icon_with_badge_count(AttachmentFile, attachment_files.count, in_list_include)
    else
      icon_with_count(AttachmentFile, attachment_files.count)
    end
  end

  def boxed_specimens
    Specimen.includes(:record_property, :user, :group, :physical_form).where(box_id: self.id)
  end

  def boxed_boxes
    Box.includes(:record_property, :user, :group).where(parent_id: self.id)
  end

  def to_tex(alias_specimen)
    lines = []
    lines << '%------------'
    lines << 'The sample names and ID of each mounted materials are listed in Table \\ref{mount:materials}.'
    lines << '%------------'
    lines << '\begin{footnotesize}'
    lines << '\begin{table}'
    lines << "\\caption{#{alias_specimen.pluralize.capitalize} mounted on #{name} (#{global_id}) as of #{Time.now.to_date}.}"
    lines << '\begin{center}'
    lines << '\begin{tabular}{lll}'
    lines << '\hline'
    lines << ["#{alias_specimen} name", "ID", "remark"].join("\t&\t") + "\\\\"
    lines << '\hline'
    specimens.each do |specimen|
      lines << [specimen.name, specimen.global_id, ""].join("\t&\t") + "\\\\"
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
    #nodes += [h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + name]
    nodes << box_node(self)
    h.raw(nodes.join("/"))
  end

  def analysis_name
    object.specimens.map{|specimen| specimen.analyses.pluck(:name)}.join(", ")
  end


  def icon(in_list_include=false)
    h.content_tag(:span, self.class.icon(in_list_include), class: (in_list_include ? "box glyphicon-active-color" : "box"))
  end


  def related_pictures
    links = []
    related_spots.each do |spot|
      links << h.content_tag(:div, spot.decorate.spots_panel , class: "col-lg-3")
    end
    spot_links.each do |spot|
      links << h.content_tag(:div, spot.decorate.spots_panel , class: "col-lg-3")
    end
    attachment_image_files.each do |file|
      links << h.content_tag(:div, file.decorate.spots_panel(spots: file.spots) , class: "col-lg-3")
    end
    h.content_tag(:div, h.raw( links.join ), class: "row spot-thumbnails")
  end

  private

  def box_node(box)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + h.link_to_if(h.can?(:read, box), box.name, box)
  end

  def icon_with_count(klass, count)
    "#{klass}Decorator".constantize.icon + h.content_tag(:span, count) if count.nonzero?
  end

  def icon_with_badge_count(klass, count, in_list_include=false)
    if count.nonzero?
      badge = h.content_tag(:span, count, :"data-klass" => "#{klass}", :"data-record_property_id" => record_property_id, class: (in_list_include ? "badge badge-active" : "badge"))
      html = h.content_tag(:span, "#{klass}Decorator".constantize.try(:icon), class: (in_list_include ? "glyphicon-active-color" : ""))
      html += h.content_tag(:a, badge, href: "#tree-#{klass}-#{record_property_id}", :"data-toggle" => "collapse", class: "collapse-active")
    end
  end
end
