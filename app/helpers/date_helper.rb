module DateHelper

  # Use time_ago_in_words if less than a month ago, otherwise display date
  def set_format_for_date(datetime)
    return "" unless datetime.is_a? Time
    if datetime > 30.days.ago && !AdminSetting.enable_test_caching?
      time_ago_in_words(datetime)
    else
      adjusted_time = datetime
      if logged_in? && current_user.preference.time_zone
        zone = current_user.preference.time_zone
        adjusted_time = datetime.in_time_zone(current_user.preference.time_zone)
      end
      adjusted_time.to_date.to_formatted_s(:rfc822)
    end
  end

end
