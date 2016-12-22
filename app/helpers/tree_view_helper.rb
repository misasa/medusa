# -*- coding: utf-8 -*-
module TreeViewHelper
  def tree(hash, classes: [], key: nil, depth: 1, in_list: [] , &block)
    blank = capture { "" }
    return blank unless hash[key]
    hash[key].inject(blank) do |str, (klass, objects)|
      tree_nodes = objects.inject(blank) do |str, obj|
        node_item = classes.include?(klass) ? tree(hash, classes: classes, key: obj.record_property_id, depth: depth + 1, in_list: in_list, &block) : ""
        str + tree_node(obj, depth, &block) + node_item
      end
      str + content_tag(:div, tree_nodes, class: (in_list.any?{|obj| obj.try(:record_property_id) == key } ? "collapse in" : "collapse"), id: "tree-#{klass}-#{key}")
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

  def icon_with_count(klass, count)
    "#{klass}Decorator".constantize.icon + h.content_tag(:span, count) if count.nonzero?
  end
end
