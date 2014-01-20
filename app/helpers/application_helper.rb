module ApplicationHelper

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

end
