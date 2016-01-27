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

  def primary_picture(width: 250, height: 250)
    attachment_file if attachment_files.present?
  end

  def family_tree
    tree = ""
    tree += file_with_id
    lis = []
    links = []
    attachment_file.attachings.each do |attaching|
       attachable = attaching.attachable
       if attachable
          spots = attachment_file.spots.find_all_by_target_uid(attachable.global_id)
          if spots.empty?
           link = attachable.decorate.try(:icon) + " "
           link += h.link_to_if(h.can?(:read, attachable), attachable.name, polymorphic_path(attachable, script_name: Rails.application.config.relative_url_root, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal", class: h.specimen_ghost(attachable))
#           link += h.link_to_if(h.can?(:read, attachable), attachable.name, polymorphic_path(attachable, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal", class: h.specimen_ghost(attachable))
           links << link
          else
           SpotDecorator.decorate_collection(spots).each do |spot|
            link = h.raw( (spot == self ? spot.xy_to_text : h.link_to(spot.xy_to_text, spot_path(spot, script_name: Rails.application.config.relative_url_root)) ) )
            link += spot.target.decorate.try(:icon) + " " + h.link_to_if(h.can?(:read, spot.target), spot.target.name, polymorphic_path(spot.target, script_name: Rails.application.config.relative_url_root, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal", class: h.specimen_ghost(spot.target))            
#            link += spot.target.decorate.try(:icon) + " " + h.link_to_if(h.can?(:read, spot.target), spot.target.name, polymorphic_path(spot.target, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal", class: h.specimen_ghost(spot.target))
            links << h.icon_tag("screenshot") + " " + link
           end        
          end
       end
    end
    SpotDecorator.decorate_collection(attachment_file.spots.where("target_uid is null or target_uid = ''")).each do |spot|
       links << h.icon_tag("screenshot") + " " + (spot == self ? spot.xy_to_text : h.link_to(spot.xy_to_text, spot_path(spot, script_name: Rails.application.config.relative_url_root)) )
    end

    lis = links.map{|link| h.content_tag(:li, link)}

    list = h.raw lis.join
    tree += h.content_tag(:ul, list)
    h.raw tree
  end

  def family_tree
    attachment_file = self.attachment_file
    return unless attachment_file
    html_class = "tree-node"
    html = h.content_tag(:div, class: html_class, "data-depth" => 1) do
      attachment_file.decorate.tree_node(false)
    end

    attachment_file.attachings.each do |attaching|
      attachable = attaching.attachable
      if attachable
        spots = attachment_file.spots.find_all_by_target_uid(attachable.global_id)
        if spots.empty?
          html += h.content_tag(:div, class: html_class, "data-depth" => 2) do
            h.route_icon(2) + attachable.decorate.tree_node(false)
          end
        else
          spots.each do |spot|
            html += h.content_tag(:div, class: html_class, "data-depth" => 2) do
              h.route_icon(2) + spot.decorate.tree_node(false)
            end
          end
        end
      end
    end
    spots_without_link = attachment_file.spots.where("target_uid is null or target_uid = ''")
    spots_without_link.each do |spot|
      html += h.content_tag(:div, class: html_class, "data-depth" => 2) do
        h.route_icon(2) + spot.decorate.tree_node(false)
      end
    end

    html
  end


  def tree_node(current=false)
    icon = h.content_tag(:span, nil, class: "glyphicon glyphicon-screenshot")
    link = current ? icon : h.link_to_if(h.can?(:read, self), icon, self, :title => spot.name )
    link += spot.name
    #node = icon + h.link_to_if(h.can?(:read, self), link, self)
    node = link
    if spot.target
      node += spot.target.decorate.try(:icon) + h.link_to_if(h.can?(:read, spot.target), spot.target.name, polymorphic_path(spot.target, script_name: Rails.application.config.relative_url_root), class: h.specimen_ghost(spot.target))
      node += h.link_to_if(h.can?(:read, spot.target), h.icon_tag('info-sign'), polymorphic_path(spot.target, script_name: Rails.application.config.relative_url_root, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal", class: h.specimen_ghost(spot.target))
    end
    node
  end

  def target_path
     # if target
     #   polymorphic_path(target, script_name: Rails.application.config.relative_url_root, format: :modal)
     # else
       spot_path(self)
     # end
  end
end
