# -*- coding: utf-8 -*-
class SpotDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers
  delegate_all
  delegate :as_json
  
  def xy_to_text(fmt = "%.2f")
  	"(#{format(fmt, spot_x)}, #{format(fmt, spot_y)})"
  end

  def file_with_id
    return unless attachment_file
    attachment_file.decorate.icon + h.link_to_if(h.can?(:read, attachment_file), " #{attachment_file.name}", attachment_file)
  end

  def name_with_id
    icon + " #{name} < #{global_id} >"
  end

  def icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-screenshot")
  end

  def target_link
    record_property = RecordProperty.find_by_global_id(target_uid)
    return name if record_property.blank? || record_property.datum.blank?
    datum = record_property.datum.try(:decorate)
	  contents = []
	  if datum
    	contents << datum.try(:icon)
    	contents << h.link_to( datum.name, datum)
	  else
		  contents << h.link_to(record_property.datum.name, record_property.datum)
	  end
    h.raw( contents.compact.join(' ') )
  end

  def cross_tag(length: 100)
    hline_tag = %Q|<line x1="#{spot.spot_x - length}" y1="#{spot.spot_y}" x2="#{spot.spot_x + length}" y2="#{spot.spot_y}" style="stroke:#{spot.stroke_color};stroke-width:#{spot.stroke_width};"/>|
    vline_tag = %Q|<line x1="#{spot.spot_x}" y1="#{spot.spot_y - length}" x2="#{spot.spot_x}" y2="#{spot.spot_y + length}" style="stroke:#{spot.stroke_color};stroke-width:#{spot.stroke_width};"/>|
    hline_tag + vline_tag
  end

  def spots_panel(width: 140, height:120)
    file = spot.attachment_file
    svg = file.decorate.picture_with_spots(width:width, height:height, spots:[spot], with_cross: true)
    svg_link = h.link_to(h.spot_path(self)) do
      svg
    end
    #tag = h.content_tag(:div, svg_link, class: "thumbnail")
    left = h.content_tag(:div, svg_link, class: "col-md-12")
    right = h.content_tag(:div, my_tree, class: "col-md-12")
    row = h.content_tag(:div, left + right, class: "row")
    tag = h.content_tag(:div, h.content_tag(:div, row, class: "panel-body"), class: "panel panel-default")
    tag
  end

  def thumblink_with_spot_info(current_spot = nil)
    file = spot.attachment_file
    svg = file.decorate.picture_with_spots(width:150, height:150, spots:[spot])
    svg_link = h.link_to(h.spot_path(self)) do
      svg
    end

    links = []
    links << h.link_to(h.icon_tag("picture"), h.attachment_file_path(file))
    link = h.link_to(h.spot_path(self)) do
      im = h.raw("")
      file.attachings.each do |attaching|
         attachable = attaching.attachable
         im += attachable.decorate.try(:icon) + attachable.name if attachable
      end
      im += h.raw (h.icon_tag("screenshot") + "#{file.spots.size}" )
      im += h.raw ("/" + h.icon_tag("screenshot"))
      im += h.raw ("#{spot.target.decorate.try(:icon)}#{spot.target.name}" )
      im
    end
    links << link
    caption = h.content_tag(:div, h.raw(my_tree), class: "caption")
    tag = h.content_tag(:div, svg_link + caption, class: "thumbnail")
    tag
#    link
  end

  def primary_picture(width: 250, height: 250)
    attachment_file if attachment_files.present?
  end

  def my_tree(current_spot = nil)
    attachment_file = self.attachment_file

    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      attachment_file.decorate.picture_link
    end

    html += h.content_tag(:div, id: "spots-#{attachment_file.id}", class: "collapse") do
      spots_tag = h.raw("")
      attachment_file.spots.each do |spot|
        spots_tag += h.content_tag(:div, class: html_class, "data-depth" => 2) do
          spot.decorate.tree_node(false)
        end
      end
      spots_tag
    end

    # html += h.content_tag(:div, class: html_class, "data-depth" => 2) do
    #     self.decorate.tree_node(false)
    # end
    html
  end


  def family_tree(current_spot = nil)
    attachment_file = self.attachment_file

    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      picture = h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-picture"), attachment_file)
      attachment_file.attachings.each do |attaching|
        attachable = attaching.attachable
        if attachable
          link = attachable.name
          icon = attachable.decorate.icon
          if h.can?(:read, attachable)
            icon += h.link_to(link, attachable) + h.link_to(h.icon_tag('info-sign'), h.polymorphic_path(attachable, script_name: Rails.application.config.relative_url_root, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal", class: h.specimen_ghost(attachable))
          else
            icon += link
          end
          picture += icon
        end
      end
      picture += h.raw (h.icon_tag("screenshot") + "#{attachment_file.spots.size}") if attachment_file.spots.size > 0      
      picture
    end

    attachment_file.spots.each do |spot|
      html += h.content_tag(:div, class: html_class, "data-depth" => 2) do
        spot.decorate.tree_node(self == spot)
      end
    end
    html
  end

  def tree_node(current=false)
    icon = h.content_tag(:span, nil, class: "glyphicon glyphicon-screenshot")
    link = current ? icon : h.link_to_if(h.can?(:read, self), icon, self, :title => spot.name )
#    link += spot.name
    #node = icon + h.link_to_if(h.can?(:read, self), link, self)
    node = link
    if spot.target
      node += spot.target.decorate.try(:icon) + h.link_to_if(h.can?(:read, spot.target), spot.target.name, polymorphic_path(spot.target, script_name: Rails.application.config.relative_url_root), class: h.specimen_ghost(spot.target))
      node += h.link_to_if(h.can?(:read, spot.target), h.icon_tag('info-sign'), polymorphic_path(spot.target, script_name: Rails.application.config.relative_url_root, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal", class: h.specimen_ghost(spot.target))
    else
      node += spot.name
    end
    node
  end

  def target_path
     if target
        polymorphic_path(target, script_name: Rails.application.config.relative_url_root)
     else
       spot_path(self, script_name: Rails.application.config.relative_url_root)
     end
  end
end
