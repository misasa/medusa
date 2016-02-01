# -*- coding: utf-8 -*-
class AnalysisDecorator < Draper::Decorator
  delegate_all
  delegate :as_json
  

  def primary_picture(width: 250, height: 250)
    attachment_files.first.decorate.picture(width: width, height: height) if attachment_files.present?
  end

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-stats") + " #{name} < #{global_id} >"
  end


  def related_pictures
    links = []
    related_spots.each do |spot|
      links << h.content_tag(:div, spot.decorate.thumblink_with_spot_info , class: "col-lg-2")
    end
    spot_links.each do |spot|
      links << h.content_tag(:div, spot.decorate.thumblink_with_spot_info , class: "col-lg-2")
    end
    attachment_image_files.each do |file|
      links << h.content_tag(:div, file.decorate.thumblink_with_spot_info , class: "col-lg-2")
    end
    h.content_tag(:div, h.raw( links.join ), class: "row spot-thumbnails")
  end

  def icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-stats")
  end
end
