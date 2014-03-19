# -*- coding: utf-8 -*-
class StoneDecorator < Draper::Decorator
  delegate_all

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
    h.image_tag(attachment_files.first.path, width: width, height: height) if attachment_files.present?
  end

  def attachment_file_image_link(attachment_file, width: 40, height: 40)
    if attachment_file.image?
      h.link_to(h.image_tag(attachment_file.path, width: width, height: height), h.attachment_file_path(attachment_file))
    else
      h.link_to h.attachment_file_path(attachment_file) do
        h.content_tag(:span, nil, class: "glyphicon glyphicon-file")
      end
    end
  end

  def family_tree
    h.tree(families.group_by(&:parent_id)) do |obj|
      obj.decorate.tree_node(self == obj)
    end
  end

  def tree_node(current=false)
    link = current ? h.content_tag(:strong, name) : name
    icon = h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud")
    icon + h.link_to(link, self) + children_count + analyses_count + bibs_count + files_count
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

  private

  def box_node(box)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-folder-close") + h.link_to(box.name, box)
  end

  def icon_with_count(icon, count)
    h.content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}") + h.content_tag(:span, count) if count.nonzero?
  end
end
