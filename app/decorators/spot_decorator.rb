# -*- coding: utf-8 -*-
class SpotDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers
  delegate_all

  def target_link
    record_property = RecordProperty.find_by_global_id(target_uid)
    return "" if record_property.blank? || record_property.datum.blank?
    h.link_to(record_property.datum.name, record_property.datum)
  end
end
