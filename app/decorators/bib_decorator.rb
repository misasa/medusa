# -*- coding: utf-8 -*-
class BibDecorator < Draper::Decorator
  delegate_all
  delegate :as_json

  def self.icon
    h.content_tag(:span, nil, class: "glyphicon glyphicon-book")
  end

  def primary_picture(width: 250, height: 250)
    attachment_files.first.decorate.picture(width: width, height: height) if attachment_files.present?
  end
 
  def family_tree
  end

  def name_with_id
    tag = h.content_tag(:span, nil, class: "glyphicon glyphicon-book")
    tag += h.raw(" ") + to_html
    tag += h.raw(" ") + h.raw("< #{h.draggable_id(global_id)} >")
    # if Settings.rplot_url
    #   tag += h.link_to(h.content_tag(:span, nil, class: "glyphicon glyphicon-eye-open"), Settings.rplot_url + '?id=' + global_id, :title => 'plot online')
    # end
    tag
  end

  def publish_badge
    if object.published
      h.published_label(object) 
    end
  end


  def tables_with_link
    contents = []
    tables.each do |table|
      contents << table.decorate.panel
    end
    unless contents.empty?
      h.raw(contents.join(" "))
    end
  end

  def tree_node(current: false, current_type: false, in_list_include: false, hash: nil)
    link = current ? h.content_tag(:strong, name) : name
    icon + h.link_to_if(h.can?(:read, self), link, self)
  end

  def specimens_count
    h.icon_with_count(Specimen, specimens.count)
  end

  def boxes_count
    h.icon_with_count(Box, boxes.count)
  end

  def analyses_count
    h.icon_with_count(Analysis, specimens.inject(0) {|count, specimen| count += specimen.analyses.size })
  end

  def places_count
    h.icon_with_count(Place, places.count)
  end

  def files_count
    h.icon_with_count(AttachmentFile, attachment_files.count)
  end

  def icon
    self.class.icon
  end
  # def as_json(options = {})
  #   super({:methods => [:author_ids, :global_id]}.merge(options))
  # end

  def author_short_year
    txt = author_short
    txt += " (#{year})" unless year.blank?
    txt
  end

  def to_html
#    html = author_short
#    html += " (#{year})" unless year.blank?
    link_txt = author_short
    link_txt += " (#{year})" unless year.blank?
    html = h.link_to_unless_current(link_txt, h.bib_path(self))
    html += " #{name}" unless name.blank?
    html += h.raw(", ") + h.content_tag(:i, journal) unless journal.blank?
    html += h.raw(", ") + h.content_tag(:b, volume) unless volume.blank?
    html += h.raw(", #{pages}") unless pages.blank?
    html += h.raw(", doi:") + h.link_to(doi, doi_link_url) unless doi.blank?
    html += h.raw(".")
    html
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


  private
  
  def author_short
    author_names = authors.map{|authors| authors.name}
    if (author_names.length == 1)
      author_names[0]
    elsif (author_names.length == 2)
      author_names.join(' & ')
    elsif (author_names.length > 2)
      first_author_name = author_names[0]
      first_author_name.split(/,/)[0] + " et al."
    else
      ""
    end
  end

end
