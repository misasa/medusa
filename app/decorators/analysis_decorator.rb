# -*- coding: utf-8 -*-
class AnalysisDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def self.icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-stats")
  end

  def primary_picture(width: 250, height: 250)
    attachment_files.first.decorate.picture(width: width, height: height) if attachment_files.present?
  end

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-stats") + h.raw(" #{name} < #{h.draggable_id(global_id)} >")
  end

  def badge_link
    h.link_to(h.content_tag(:span, self.chemistries.size, class:"badge"), h.analysis_path(self, format: :modal), "data-toggle" => "modal", "data-target" => "#show-modal")
  end

  def tree_node(current: false, current_type: false, in_list_include: false)
    link = current ? h.content_tag(:strong, name) : name
    icon + h.link_to_if(h.can?(:read, self), link, self)
  end

  def publish_badge
    if self.published
      h.published_label(self)
#    else
#      h.link_to(h.content_tag(:button, "publish", type: "button", class: "btn btn-danger"), h.publish_table_path(self.id), method: :put) 
#      h.content_tag(:button, "publish", type: "button", class: "btn btn-primary")
    end
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

  def icon
    self.class.icon
  end
end
