# -*- coding: utf-8 -*-
class StoneDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + " #{name} < #{global_id} >"
  end

  def path
    # TODO: pending
    "/foo/baa/baz/me"
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
end
