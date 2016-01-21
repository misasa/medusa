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
    attachment_file.decorate.icon + h.link_to_if(h.can?(:read, attachment_file), " #{attachment_file.name} < #{attachment_file.global_id} >", attachment_file)
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
end
