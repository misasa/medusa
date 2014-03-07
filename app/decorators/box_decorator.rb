# -*- coding: utf-8 -*-
class BoxDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + " #{name} < #{global_id} >"
  end

  def primary_picture(width: 250, height: 250)
    h.image_tag(attachment_files.first.path, width: width, height: height) if attachment_files.present?
  end

  def family_tree
    h.tree(families.group_by(&:parent_id)) do |obj|
      obj.decorate.tree_node(self == obj)
    end
  end

  def tree_node(current=false)
    link = current ? h.content_tag(:strong, name) : name
    h.link_to(link, self)
  end

  def boxed_stones
    Stone.includes(:record_property, :user, :group, :physical_form).where(box_id: self.id)
  end

  def boxed_boxes
    Box.includes(:record_property, :user, :group).where(parent_id: self.id)
  end
end
