=begin
------------------------------------------------- Class: DateTime < Date
     Class representing a date and time.

     See the documentation to the file date.rb for an overview.

     DateTime objects are immutable once created.


Other methods.
--------------
     The following methods are defined in Date, but declared private
     there. They are made public in DateTime. They are documented here.

     hour()
     Get the hour-of-the-day of the time. This is given using the
     24-hour clock, counting from midnight. The first hour after
     midnight is hour 0; the last hour of the day is hour 23.

     min()
     Get the minute-of-the-hour of the time.

     sec()
     Get the second-of-the-minute of the time.

     sec_fraction()
     Get the fraction of a second of the time. This is returned as a
     +Rational+. The unit is in days. I do NOT recommend you to use this
     method.

     zone()
     Get the time zone as a String. This is representation of the time
     offset such as "+1000", not the true time-zone name.

     offset()
     Get the time zone offset as a fraction of a day. This is returned
     as a +Rational+.

     new_offset(of=0)
     Create a new DateTime object, identical to the current one, except
     with a new time zone offset of +of+. +of+ is the new offset from
     UTC as a fraction of a day.

------------------------------------------------------------------------


Includes:
---------
     ActiveSupport::CoreExtensions::DateTime::Calculations(advance, ago,
     at_beginning_of_day, at_midnight, beginning_of_day, change,
     end_of_day, in, midnight, seconds_since_midnight, since),
     ActiveSupport::CoreExtensions::DateTime::Conversions(readable_inspe
     ct, to_date, to_datetime, to_formatted_s, to_time, xmlschema),
     ActiveSupport::CoreExtensions::Time::Behavior(acts_like_time?)


Class methods:
--------------
     _strptime, civil, commercial, jd, ordinal, parse, strptime


Instance methods:
-----------------
     strftime

=end
class DateTime < Date
  include Comparable

  def self.now(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- DateTime::jd
  #      DateTime::jd(jd=0, h=0, min=0, s=0, of=0, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new DateTime object corresponding to the specified Julian
  #      Day Number +jd+ and hour +h+, minute +min+, second +s+.
  # 
  #      The 24-hour clock is used. Negative values of +h+, +min+, and +sec+
  #      are treating as counting backwards from the end of the next larger
  #      unit (e.g. a +min+ of -2 is treated as 58). No wraparound is
  #      performed. If an invalid time portion is specified, an
  #      ArgumentError is raised.
  # 
  #      +of+ is the offset from UTC as a fraction of a day (defaults to 0).
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  #      All day/time values default to 0.
  # 
  def self.jd(arg0, arg1, *rest)
  end

  # ------------------------------------------------------ DateTime::ordinal
  #      DateTime::ordinal(y=-4712, d=1, h=0, min=0, s=0, of=0, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new DateTime object corresponding to the specified Ordinal
  #      Date and hour +h+, minute +min+, second +s+.
  # 
  #      The 24-hour clock is used. Negative values of +h+, +min+, and +sec+
  #      are treating as counting backwards from the end of the next larger
  #      unit (e.g. a +min+ of -2 is treated as 58). No wraparound is
  #      performed. If an invalid time portion is specified, an
  #      ArgumentError is raised.
  # 
  #      +of+ is the offset from UTC as a fraction of a day (defaults to 0).
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  #      +y+ defaults to -4712, and +d+ to 1; this is Julian Day Number day
  #      0. The time values default to 0.
  # 
  def self.ordinal(arg0, arg1, *rest)
  end

  # ----------------------------------------------------- DateTime::strptime
  #      DateTime::strptime(str='-4712-01-01T00:00:00+00:00', fmt='%FT%T%z',
  #      sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new DateTime object by parsing from a String according to
  #      a specified format.
  # 
  #      +str+ is a String holding a date-time representation. +fmt+ is the
  #      format that the date-time is in. See date/format.rb for details on
  #      supported formats.
  # 
  #      The default +str+ is '-4712-01-01T00:00:00+00:00', and the default
  #      +fmt+ is '%FT%T%z'. This gives midnight on Julian Day Number day 0.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  #      An ArgumentError will be raised if +str+ cannot be parsed.
  # 
  def self.strptime(arg0, arg1, *rest)
  end

  # --------------------------------------------------- DateTime::commercial
  #      DateTime::commercial(y=1582, w=41, d=5, h=0, min=0, s=0, of=0,
  #      sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new DateTime object corresponding to the specified
  #      Commercial Date and hour +h+, minute +min+, second +s+.
  # 
  #      The 24-hour clock is used. Negative values of +h+, +min+, and +sec+
  #      are treating as counting backwards from the end of the next larger
  #      unit (e.g. a +min+ of -2 is treated as 58). No wraparound is
  #      performed. If an invalid time portion is specified, an
  #      ArgumentError is raised.
  # 
  #      +of+ is the offset from UTC as a fraction of a day (defaults to 0).
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  #      +y+ defaults to 1582, +w+ to 41, and +d+ to 5; this is the Day of
  #      Calendar Reform for Italy and the Catholic countries. The time
  #      values default to 0.
  # 
  def self.commercial(arg0, arg1, *rest)
  end

  def self.new(arg0, arg1, *rest)
  end

  # ---------------------------------------------------- DateTime::_strptime
  #      DateTime::_strptime(str, fmt='%FT%T%z')
  # ------------------------------------------------------------------------
  #      (no description...)
  def self._strptime(arg0, arg1, arg2, *rest)
  end

  # -------------------------------------------------------- DateTime::civil
  #      DateTime::civil(y=-4712, m=1, d=1, h=0, min=0, s=0, of=0, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new DateTime object corresponding to the specified Civil
  #      Date and hour +h+, minute +min+, second +s+.
  # 
  #      The 24-hour clock is used. Negative values of +h+, +min+, and +sec+
  #      are treating as counting backwards from the end of the next larger
  #      unit (e.g. a +min+ of -2 is treated as 58). No wraparound is
  #      performed. If an invalid time portion is specified, an
  #      ArgumentError is raised.
  # 
  #      +of+ is the offset from UTC as a fraction of a day (defaults to 0).
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  #      +y+ defaults to -4712, +m+ to 1, and +d+ to 1; this is Julian Day
  #      Number day 0. The time values default to 0.
  # 
  def self.civil(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- DateTime::parse
  #      DateTime::parse(str='-4712-01-01T00:00:00+00:00', comp=false,
  #      sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new DateTime object by parsing from a String, without
  #      specifying the format.
  # 
  #      +str+ is a String holding a date-time representation. +comp+
  #      specifies whether to interpret 2-digit years as 19XX (>= 69) or
  #      20XX (< 69); the default is not to. The method will attempt to
  #      parse a date-time from the String using various heuristics; see
  #      #_parse in date/format.rb for more details. If parsing fails, an
  #      ArgumentError will be raised.
  # 
  #      The default +str+ is '-4712-01-01T00:00:00+00:00'; this is Julian
  #      Day Number day 0.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.parse(arg0, arg1, *rest)
  end

  def sec
  end

  def zone
  end

  def sec_fraction
  end

  # ------------------------------------------------------ DateTime#strftime
  #      strftime(fmt='%FT%T%:z')
  # ------------------------------------------------------------------------
  #      (no description...)
  def strftime(arg0, arg1, *rest)
  end

  def min
  end

  def new_offset(arg0, arg1, *rest)
  end

  def newof(arg0, arg1, *rest)
  end

  def hour
  end

  def offset
  end

  def of(arg0, arg1, *rest)
  end

end
