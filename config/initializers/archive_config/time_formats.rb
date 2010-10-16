Date::DATE_FORMATS[:date_for_comment_test] = "%a, %d %b %Y"
Time::DATE_FORMATS[:time_for_comment_test] = "%a, %d %b %Y %H:%M"

# this returns: hour:minuteAM/PM Timezone Mon/Tue day# January/February 4-digit Year
Time::DATE_FORMATS[:time_for_mailers] = "%I:%M%p %Z %a %d %B %Y"
