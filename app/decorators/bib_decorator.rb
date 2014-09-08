# -*- coding: utf-8 -*-
class BibDecorator < Draper::Decorator
  delegate_all
  delegate :to_json

  def primary_picture(width: 250, height: 250)
    attachment_files.first.decorate.picture(width: width, height: height) if attachment_files.present?
  end

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-book") + " #{name} < #{global_id} >"
  end

  def to_html
    html = author_short
    html += " (#{year})" unless year.blank?
    html += " #{name}" unless name.blank?
    html += ", <i>#{journal}</i>" unless journal.blank?
    html += ", <b>#{volume}</b>" unless volume.blank?
    html += ", #{pages}" unless pages.blank?
    html += " at " + updated_at.strftime("%Y-%m-%d %H:%M")
    html += "."
    html
  end

  private
  
  def author_short
    author_names = authors.map{|authors| authors.name}
    if (author_names.length == 1)
      author_names[0]
    elsif (author_names.length == 2)
      author_names.join(' & ')
    elsif (author_names.length > 2)
      author_names[0] + " et al."
    else
      ""
    end
  end

end
