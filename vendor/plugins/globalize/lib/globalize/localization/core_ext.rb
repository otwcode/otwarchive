# This module supplies a bunch of localization-related core extensions to ruby
# built-in and standard classes.

module Globalize # :nodoc:
  module CoreExtensions # :nodoc:

    module String

      # Indicates direction of text (usually +ltr+ [left-to-right] or
      # +rtl+ [right-to-left].
      attr_accessor :direction

      # Translates the string into the active language. If there is a
      # quantity involved, it can be set with the +arg+ parameter. In this case
      # string should contain the code <tt>%d</tt>, which will be substituted with
      # the supplied number.
      #
      # To substitute a +string+, give it as the +arg+ parameter. It will be
      # substituted for <tt>%s</dd>.
      #
      # If there is no translation available, +default+ will be returned, or
      # if it's not supplied, the original string will be returned.
      def translate(default = nil, arg = nil, namespace = nil)
        Locale.translate(self, default, arg, namespace)
      end
      alias :t :translate


      # Translates the string into the active language using the supplied namespace.
      #
      # Example:
      #          <tt>"draw".t -> "dibujar"</tt>
      #          <tt>"draw".tn(:lottery) -> "seleccionar"</tt>
      def translate_with_namespace(namespace, arg = nil, default = nil)
        Locale.translate(self, default, arg, namespace.to_s)
      end

      alias :tn :translate_with_namespace

      # Translates the string into the active language using the supplied namespace.
      # This is equivalent to translate_with_namespace(arg).
      #
      # Example:
      #          <tt>"draw".t -> "dibujar"</tt>
      #          <tt>"draw" >> 'lottery' -> "seleccionar"</tt>
      def >>(namespace)
        translate_with_namespace(namespace, nil, nil)
      end

      # Translates the string into the active language. This is equivalent
      # to translate(arg).
      #
      # Example: <tt>"There are %d items in your cart" / 1 -> "There is one item in your cart"</tt>
      def /(arg)
        translate(nil, arg)
      end

    end

    module Symbol
      # Translates the symbol into the active language. Underscores are
      # converted to spaces.
      #
      # If there is no translation available, +default+ will be returned, or
      # if it's not supplied, the original string will be returned.
      def translate(default = nil, namespace = nil)
        Locale.translate(self, default, namespace)
      end
      alias :t :translate
    end

    module Object
      # Translates the supplied string into the active language. If there is a
      # quantity involved, it can be set with the +arg+ parameter. In this case
      # string should contain the code <tt>%d</tt>, which will be substituted with
      # the supplied number.
      #
      # If there is no translation available, +default+ will be returned, or
      # if it's not supplied, the original string will be returned.
      #
      # <em>Note: This method is deprectated and is supplied for backward
      # compatibility with other translation packages, notable gettext.</em>
      def _(str, default = nil, arg = nil)
        Locale.translate(str, default, arg)
      end
    end

    module Integer
      # Returns the integer in String form, according to the rules of the
      # currently active locale.
      def localize( base = 10 )
        str = self.to_s( base )
        if (base == 10)
          if Locale.active?
            delimiter = Locale.active.thousands_sep
            number_grouping_scheme = Locale.active.number_grouping_scheme
          end
          delimiter ||= ','
          number_grouping_scheme ||= :western
          number_grouping_scheme == :indian ?
            str.gsub(/(\d)(?=((\d\d\d)(?!\d))|((\d\d)+(\d\d\d)(?!\d)))/) { |match|
              match + delimiter } :
            str.gsub(/(\d)(?=(\d\d\d)+(?!\d))/) { |match| match + delimiter }
        else
          str
        end
      end
      alias :loc :localize
    end

    module Float
      # Returns the integer in String form, according to the rules of the
      # currently active locale.
      #
      # Example: <tt>123456.localize -> 123.456</tt> (German locale)
      def localize
        str = self.to_s
        if str =~ /^[\d\.]+$/
          if Locale.active?
            active_locale = Locale.active
            delimiter = active_locale.thousands_sep
            decimal   = active_locale.decimal_sep
            number_grouping_scheme = active_locale.number_grouping_scheme
          end
          delimiter ||= ','
          decimal   ||= '.'
          number_grouping_scheme ||= :western

          int, frac = str.split('.')
          number_grouping_scheme == :indian ?
            int.gsub!(/(\d)(?=((\d\d\d)(?!\d))|((\d\d)+(\d\d\d)(?!\d)))/) { |match|
              match + delimiter} :
            int.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/) { |match| match + delimiter }
          int + decimal + frac
        else
          str
        end
      end
      alias :loc :localize
    end

    module Time
      # Acts the same as #strftime, but returns a localized version of the
      # formatted date/time string.
      def localize(format)
        # unabashedly stole this snippet from Tadayoshi Funaba's Date class
        o = ''
        format.scan(/%[EO]?.|./o) do |c|
          cc = c.sub(/^%[EO]?(.)$/o, '%\\1')
          case cc
          when '%A'; o << "#{::Date::DAYNAMES[wday]} [weekday]".t(::Date::DAYNAMES[wday])
          when '%a'; o << "#{::Date::ABBR_DAYNAMES[wday]} [abbreviated weekday]".t(::Date::ABBR_DAYNAMES[wday])
          when '%B'; o << "#{::Date::MONTHNAMES[mon]} [month]".t(::Date::MONTHNAMES[mon])
          when '%b'; o << "#{::Date::ABBR_MONTHNAMES[mon]} [abbreviated month]".t(::Date::ABBR_MONTHNAMES[mon])
          when '%c'; o << ((Locale.active? && !Locale.active.date_format.nil?) ?
            localize(Locale.active.date_format) : strftime('%Y-%m-%d'))
          when '%p'; o << if hour < 12 then 'AM [Ante Meridiem]'.t("AM") else 'PM [Post Meridiem]'.t("PM") end
          else;      o << c
          end
        end
        strftime(o)
      end
      alias :loc :localize
    end

    module Date
      # Acts the same as #strftime, but returns a localized version of the
      # formatted date/time string.
      def localize(format)
        # unabashedly stole this snippet from Tadayoshi Funaba's Date class
        o = ''
        format.scan(/%[EO]?.|./o) do |c|
          cc = c.sub(/^%[EO]?(.)$/o, '%\\1')
          case cc
          when '%A'; o << "#{::Date::DAYNAMES[wday]} [weekday]".t(::Date::DAYNAMES[wday])
          when '%a'; o << "#{::Date::ABBR_DAYNAMES[wday]} [abbreviated weekday]".t(::Date::ABBR_DAYNAMES[wday])
          when '%B'; o << "#{::Date::MONTHNAMES[mon]} [month]".t(::Date::MONTHNAMES[mon])
          when '%b'; o << "#{::Date::ABBR_MONTHNAMES[mon]} [abbreviated month]".t(::Date::ABBR_MONTHNAMES[mon])
          when '%c'; o << ((Locale.active? && !Locale.active.date_format.nil?) ?
            localize(Locale.active.date_format) : strftime('%Y-%m-%d'))
          when '%p'; o << if hour < 12 then 'AM [Ante Meridiem]'.t("am") else 'PM [Post Meridiem]'.t("am") end
          when '%P'; o << if hour < 12 then 'AM [Ante Meridiem]'.t("AM") else 'PM [Post Meridiem]'.t("PM") end
          else;      o << c
          end
        end
        strftime(o)
      end
      alias :loc :localize
    end

  end
end
