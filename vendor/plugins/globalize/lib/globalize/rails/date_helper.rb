require "date"

module ActionView
  module Helpers
    # The Date Helper primarily creates select/option tags for different kinds of dates and date elements. All of the select-type methods
    # share a number of common options that are as follows:
    #
    # * <tt>:prefix</tt> - overwrites the default prefix of "date" used for the select names. So specifying "birthday" would give
    #   birthday[month] instead of date[month] if passed to the select_month method.
    # * <tt>:include_blank</tt> - set to true if it should be possible to set an empty date.
    # * <tt>:discard_type</tt> - set to true if you want to discard the type part of the select name. If set to true, the select_month
    #   method would use simply "date" (which can be overwritten using <tt>:prefix</tt>) instead of "date[month]".
    module DateHelper # :nodoc:
      def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round

        case distance_in_minutes
          when 0..1
            return (distance_in_minutes==0) ? 'less than a minute'.t : ('%d minutes' / 1) unless include_seconds
            case distance_in_seconds
              when 0..4   then 'less than %d seconds' / 5
              when 5..9  then 'less than %d seconds' / 10
              when 10..19 then 'less than %d seconds' / 20
              when 20..39 then 'half a minute'.t
              when 40..59 then 'less than a minute'.t
              else             '%d minutes' / 1
            end

          when 2..44           then '%d minutes' / distance_in_minutes
          when 45..89          then 'about %d hours' / 1
          when 90..1439        then 'about %d hours' / (distance_in_minutes.to_f / 60.0).round
          when 1440..2879      then '%d days' / 1
          when 2880..43199     then 'about %d days' / (distance_in_minutes.to_f / 1440.0).round
          when 43200..86399    then 'about %d months' / 1
          when 86400..525959   then 'about %d months' / (distance_in_minutes.to_f / 43200.0).round 
          when 525960..1051919 then 'about %d years' / 1
          else                      'over %d years' / (distance_in_minutes.to_f / 525960.0).round
        end
      end

      # Returns a select tag with options for each of the months January through December with the current month selected.
      # The month names are presented as keys (what's shown to the user) and the month numbers (1-12) are used as values
      # (what's submitted to the server). It's also possible to use month numbers for the presentation instead of names --
      # set the <tt>:use_month_numbers</tt> key in +options+ to true for this to happen. If you want both numbers and names,
      # set the <tt>:add_month_numbers</tt> key in +options+ to true. Examples:
      #
      #   select_month(Date.today)                             # Will use keys like "January", "March"
      #   select_month(Date.today, :use_month_numbers => true) # Will use keys like "1", "3"
      #   select_month(Date.today, :add_month_numbers => true) # Will use keys like "1 - January", "3 - March"
      #
      # Override the field name using the <tt>:field_name</tt> option, 'month' by default.
      #
      # If you would prefer to show month names as abbreviations, set the
      # <tt>:use_short_month</tt> key in +options+ to true.
      def select_month(date, options = {})
        val = date ? (date.kind_of?(Fixnum) ? date : date.month) : ''
        if options[:use_hidden]
          hidden_html(options[:field_name] || 'month', val, options)
        else
          month_options = []
          month_names = options[:use_month_names] || (options[:use_short_month] ? Date::ABBR_MONTHNAMES : Date::MONTHNAMES)
          abbr_key = options[:use_short_month] ? 'abbreviated month' : 'month'
          month_names.unshift(nil) if month_names.size < 13
          1.upto(12) do |month_number|
            month_name = if options[:use_month_numbers]
              month_number
            elsif options[:add_month_numbers]
              month_number.to_s + ' - ' + "#{month_names[month_number]} [#{abbr_key}]".t(month_names[month_number])
            else
              "#{month_names[month_number]} [#{abbr_key}]".t(month_names[month_number])
            end

            month_options << ((val == month_number) ?
              %(<option value="#{month_number}" selected="selected">#{month_name}</option>\n) :
              %(<option value="#{month_number}">#{month_name}</option>\n)
            )
          end
          select_html(options[:field_name] || 'month', month_options, options)
        end
      end
    end

  end
end