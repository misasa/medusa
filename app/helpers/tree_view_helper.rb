# -*- coding: utf-8 -*-
module TreeViewHelper
  def tree(hash, key=nil, depth=1, &block)
    blank = capture { "" }
    return blank unless hash[key]
    hash[key].inject(blank) do |str, obj|
      str + tree_node(obj, depth, &block) + tree(hash, obj.id, depth + 1, &block)
    end
  end

  private

  def tree_node(obj, depth, &block)
    html_class = "tree-node"
    html_class += " ghost" if obj.try(:ghost?)
    content_tag(:div, class: html_class, "data-depth" => depth) do
      block.call(obj)
#      depth < 2 ? block.call(obj) : route_icon(depth) + block.call(obj)
    end
  end

  def route_icon(depth)
    content_tag(:span, nil, class: "glyphicon glyphicon-arrow-right")
  end

  def icon_with_count(icon, count)
    content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}") + content_tag(:span, count) if count.nonzero?
  end

end
