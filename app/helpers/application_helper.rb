module ApplicationHelper

  def content_tag_if(boolean, name, content_or_options_with_block = nil, options = nil, escape = true, &block)
    if boolean
      content_tag(name, content_or_options_with_block, options, escape, &block)
    end
  end

  def format_date(date)
    date.present? ? Date.parse(date).strftime("%Y-%m-%d") : ""
  end

  def difference_from_now(time)
    return unless time
    now = Time.now
    sec = now - time
    today_in_sec = now - now.at_beginning_of_day
    yesterday_in_sec = now - 1.days.ago.at_beginning_of_day

    if sec <= today_in_sec
      if sec < 60
        "#{sec.floor} s ago"
      elsif sec < (60*60)
        "#{(sec / 60).floor} m ago"
      elsif sec < (60*60*24)
        "#{(sec / (60*60)).floor} h ago"
      end
    elsif (today_in_sec < sec) && (sec < yesterday_in_sec)
      "yesterday, #{time.strftime("%H:%M")}"
    else
      time.to_date
    end
  end

  def error_notification(errors)
    return if errors.blank?
    render partial: "parts/error_notification", locals: {errors: errors}
  end

  def qrcode(value, alt: nil, size: nil)
    alt ||= value
    image_tag(qrcode_path(value), alt: alt, size: size)
  end
  
  def li_if_exist(prefix, value)
    return if value.blank?
    content_tag(:li, prefix + value.to_s, {}, false)
  end

  def data_count(array)
    return "" if array.nil? || array.empty?
    " (#{array.size})"
  end

  def active_if_current(tabname)
    if params[:tab]
      " active" if params[:tab] == tabname
    else 
      " active" if tabname == "at-a-glance" 
    end
  end

  def tab_param(filename)
    "?tab=#{tabname_from_filename(filename)}"
  end

  def hidden_tabname_tag(filename)
    hidden_field_tag :tab,tabname_from_filename(filename)
  end

  def path_entry_under(path, obj)
    items = path.to_a
    index = items.index(obj)
    if index
      items = items[(index + 1)..-1]
    end
    links = []
    items.each do |content|
      if content
        links << link_to_if(can?(:read, content), content.name, content, class: specimen_ghost(content))
      else
        lins << [ "--" ]
      end
    end
    raw links.join("/")
  end
  
  def specimen_ghost(obj, html_class="")
    if obj.instance_of?(Specimen)
      html_class += " ghost" if obj.ghost?
    end
    html_class
  end


  def icon_tag(icon)
    content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}")
  end

  private

  def tabname_from_filename(filename)
    File.basename(filename).sub(/^_/,"").sub(/.html.erb$/,"")
  end

end
