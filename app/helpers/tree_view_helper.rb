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
    content_tag(:div, class: "tree-node", "data-depth" => depth) do
      depth < 2 ? block.call(obj) : route_icon(depth) + block.call(obj)
    end
  end

  def route_icon(depth)
    content_tag(:span, nil, class: "glyphicon glyphicon-arrow-right")
  end
end
