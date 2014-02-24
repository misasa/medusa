module ApplicationHelper

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
      "yesterday, #{time.hour}:#{time.min}"
    else
      time.to_date
    end
  end

  def error_notification(errors)
    return if errors.blank?
    render partial: "parts/error_notification", locals: {errors: errors}
  end

  def records_search_matcher(attribute)
    str = "datum_of_Stone_type_#{attribute}_or_"
    str += "datum_of_Box_type_#{attribute}_or_"
    str += "datum_of_Place_type_#{attribute}_or_"
    str += "datum_of_Analysis_type_#{attribute}_or_"
    str += "datum_of_Bib_type_#{attribute}_or_"
    str += "datum_of_AttachmentFile_type_#{attribute}"
    str
  end
end
