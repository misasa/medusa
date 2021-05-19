module ApplicationHelper
  def product_version
    "Medusa v#{Medusa::Application.version}"
  end

  def server_utc_time
    Time.now.utc.strftime("%H:%M:%S UTC")
  end

  def mantra(msg, opts = {})
    title = opts[:title] || "guide"
    popover_button(title, msg, opts)
  end

  def tooltip_info_sign(msg, opts = {})
    content_tag(:a, title: msg, data:{toggle: "tooltip", placement: "right"}) do
      content_tag(:span, nil, class:"fas fa-info-circle")
    end
  end

  def popover_info_sign(title, msg, opts = {})
    content_tag(:a, title: title, data:{toggle: "popover", content: msg, placement: "auto", trigger: "hover"}) do
      content_tag(:span, nil, class:"fas fa-info-circle")
    end
  end

  def popover_button(title, msg, opts = {})
    data = {toggle: "popover", content: msg, placement: "auto", trigger: "hover"}.merge(opts)
    content_tag(:button, type: "button", class: "btn btn-info btn-xs", title: opts[:title], data:data) do
      title
    end
  end

  def show_info_with_label(label, msg, opts = {})
    content_tag(:span, label, class: "label label-info") + content_tag(:small, msg, style:"margin-left:0.5rem;" )  
  end

  def published_label(obj)
    if obj.published
      content_tag(:span, "pub", class: "label label-danger")
    end
  end

  def show_title(obj)
    tag = obj.name_with_id
    tag += raw(" ") + published_label(obj) if obj.published
    tag
  end

  def list_title(obj, opts = {})
    return unless obj
    
    if obj.respond_to?(:decorate)
      obj = obj.decorate
      tag = obj.try(:icon) ? obj.icon + raw(" ") + obj.name : obj.name
    else
      tag = obj.name
    end
    tag += raw(" ") + content_tag(:small, "<" + obj.global_id + ">" ) if opts[:with_global_id]
    tag += raw(" ") + published_label(obj) if obj.published
    tag
  end

  def url_for_tile(_image_or_layer, zoom=0,x=0,y=0)
    surface = _image_or_layer.surface
    url = "#{root_path}system/maps/#{surface.global_id}/"
    if _image_or_layer.is_a?(SurfaceLayer)
      url += "layers/#{_image_or_layer.id}/"
    else
      image = _image_or_layer.image
      url += "#{image.id}/"
    end
    url += "#{zoom}/#{x}_#{y}.png"
    url
  end

  def content_tag_if(boolean, name, content_or_options_with_block = nil, options = nil, escape = true, &block)
    if boolean
      content_tag(name, content_or_options_with_block, options, escape, &block)
    end
  end

  def display_type_for(target)
    content_tag(:a, target, href: "#display-type-#{target}", class: "btn radio-button-group")
  end

  def display_plot(obj)
    content_tag(:div, class:"hidden", id:"display-type-plot") do
      rplot_iframe obj
    end
      # <div class="hidden" id="display-type-plot">
      # <%= @surface.rplot_iframe %>
      # </div>  
  end



  def rplot_iframe(obj, size = '800', width = 800, height = 800)
    tag = ""
    #tag += content_tag(:iframe, nil, src: obj.rplot_url, width: width, height: height, frameborder: "yes" , class: "embed-responsive-item")
    tag += javascript_include_tag("https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.min.js")
    tag += content_tag(:style, "iframe {min-width: 100%;height: 500px;}")
    tag += content_tag(:iframe, nil, id: "myIframe", src: obj.rplot_url, scrolling: "no", frameborder: "no")
    tag += javascript_tag("iFrameResize({heightCalculationMethod: 'taggedElement'},'#myIframe');")
    raw tag
  end

  def rmap_iframe(obj)
    content_tag(:iframe, nil, id: "myMapIframe", src: obj.rmap_url, frameborder: "no")
  end

  def format_date(date)
    date.present? ? Date.parse(date).strftime("%Y-%m-%d") : ""
  end

  def history_title(path)
    html = path.boxes.map { |content| content_tag(:span, nil, class:"fas fa-folder") + ( content ? link_to_if(can?(:read, content), content.name, content) : "--" ) }.join("/") 
    html += " " + content_tag(:span, distance_of_time_in_words(path.duration), class:"label label-default")
    raw html
  end

  def timeline(in_at, out_at)
    flag_more_than = false
    if in_at
      t1 = in_at
    else
      oldest = Path.oldest
      if oldest
        t1 = oldest.brought_in_at
        flag_more_than = true
      end
    end

    if out_at
      t2 = out_at
    else
      t2 = Time.zone.now
      out_at = t2
      flag_more_than = true
    end

    words = []
    html = ""
    # if t2 && t1
    #   #words << "more than " if flag_more_than
    #   #words << t2 - t1
    #   words << content_tag(:span, distance_of_time_in_words(t2 - t1), class:"label label-default")
    # end
    stamps = []
    if in_at
      stamps << in_at.strftime("%Y-%m-%d %H:%M")
    end
    stamps << content_tag(:span, nil, class: "fas fa-arrow-right")

    if out_at
      stamps << out_at.strftime("%Y-%m-%d %H:%M")
    end
    words << stamps.join(" ")
    raw words.join(" ")
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
      #" active" if tabname == "at-a-glance"
      " active" if tabname == "dashboard"
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
    content_tag(:span, nil, class: "fas fa-#{icon}")
  end

  def draggable_id(id)
    id = content_tag(:span, id, class: "global-id", draggable: true)
    content_tag(:span, nil, class: "fas fa-exchange-alt") + id
  end

  private

  def tabname_from_filename(filename)
    File.basename(filename).sub(/^_/,"").sub(/.html.erb$/,"")
  end

end
