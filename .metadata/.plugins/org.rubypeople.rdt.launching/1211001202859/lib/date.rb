=begin
------------------------------------------------------------ Class: Date
     Class representing a date.

     See the documentation to the file date.rb for an overview.

     Internally, the date is represented as an Astronomical Julian Day
     Number, +ajd+. The Day of Calendar Reform, +sg+, is also stored,
     for conversions to other date formats. (There is also an +of+ field
     for a time zone offset, but this is only for the use of the
     DateTime subclass.)

     A new Date object is created using one of the object creation class
     methods named after the corresponding date format, and the
     arguments appropriate to that date format; for instance,
     Date::civil() (aliased to Date::new()) with year, month, and
     day-of-month, or Date::ordinal() with year and day-of-year. All of
     these object creation class methods also take the Day of Calendar
     Reform as an optional argument.

     Date objects are immutable once created.

     Once a Date has been created, date values can be retrieved for the
     different date formats supported using instance methods. For
     instance, #mon() gives the Civil month, #cwday() gives the
     Commercial day of the week, and #yday() gives the Ordinal day of
     the year. Date values can be retrieved in any format, regardless of
     what format was used to create the Date instance.

     The Date class includes the Comparable module, allowing date
     objects to be compared and sorted, ranges of dates to be created,
     and so forth.

------------------------------------------------------------------------


Includes:
---------
     Comparable(<, <=, ==, >, >=, between?)


Constants:
----------
     ABBR_DAYNAMES:   %w(Sun Mon Tue Wed Thu Fri Sat)
     ABBR_MONTHNAMES: [nil] + %w(Jan Feb Mar Apr May Jun                
                                     Jul Aug Sep Oct Nov Dec)
     DAYNAMES:        %w(Sunday Monday Tuesday Wednesday Thursday Friday
                      Saturday)
     ENGLAND:         2361222
     GREGORIAN:       -Infinity.new
     ITALY:           2299161
     JULIAN:          Infinity.new
     MONTHNAMES:      [nil] + %w(January February March April May June
                      July                           August September
                      October November December)


Class methods:
--------------
     _load, _parse, _strptime, ajd_to_amjd, ajd_to_jd, amjd_to_ajd,
     civil, civil_to_jd, commercial, commercial_to_jd,
     day_fraction_to_time, gregorian?, gregorian_leap?, jd, jd_to_ajd,
     jd_to_civil, jd_to_commercial, jd_to_ld, jd_to_mjd, jd_to_ordinal,
     jd_to_wday, julian?, julian_leap?, ld_to_jd, mjd_to_jd, new, now,
     ordinal, ordinal_to_jd, parse, s3e, strptime, time_to_day_fraction,
     today, valid_civil?, valid_commercial?, valid_jd?, valid_ordinal?,
     valid_time?


Instance methods:
-----------------
     +, -, <<, <=>, ===, >>, _dump, ajd, amjd, asctime, civil,
     commercial, ctime, cwday, cweek, cwyear, day, day_fraction, downto,
     england, eql?, gregorian, gregorian?, hash, hour, inspect, italy,
     jd, julian, julian?, ld, leap?, mday, min, mjd, mon, month,
     new_offset, new_start, next, next_day, offset, ordinal, sec,
     sec_fraction, start, step, strftime, succ, time, to_s, to_yaml,
     upto, wday, weeknum0, weeknum1, wnum0, wnum1, yday, year, zone

=end
class Date < Object
  include Comparable

  # -------------------------------------------------- Date::gregorian_leap?
  #      Date::gregorian_leap?(y)
  # ------------------------------------------------------------------------
  #      Is a year a leap year in the Gregorian calendar?
  # 
  #      All years divisible by 4 are leap years in the Gregorian calendar,
  #      except for years divisible by 100 and not by 400.
  # 
  def self.gregorian_leap?(arg0)
  end

  # ---------------------------------------------------------- Date::ordinal
  #      Date::ordinal(y=-4712, d=1, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new Date object from an Ordinal Date, specified by year
  #      +y+ and day-of-year +d+. +d+ can be negative, in which it counts
  #      backwards from the end of the year. No year wraparound is
  #      performed, however. An invalid value for +d+ results in an
  #      ArgumentError being raised.
  # 
  #      +y+ defaults to -4712, and +d+ to 1; this is Julian Day Number day
  #      0.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.ordinal(arg0, arg1, *rest)
  end

  # ---------------------------------------------------- Date::jd_to_ordinal
  #      Date::jd_to_ordinal(jd, sg=GREGORIAN)
  # ------------------------------------------------------------------------
  #      Convert a Julian Day Number to an Ordinal Date.
  # 
  #      +jd+ is the Julian Day Number to convert. +sg+ specifies the Day of
  #      Calendar Reform.
  # 
  #      Returns the corresponding Ordinal Date as [year, day_of_year]
  # 
  def self.jd_to_ordinal(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------ Date::amjd_to_ajd
  #      Date::amjd_to_ajd(amjd)
  # ------------------------------------------------------------------------
  #      Convert an Astronomical Modified Julian Day Number to an
  #      Astronomical Julian Day Number.
  # 
  def self.amjd_to_ajd(arg0)
  end

  def self.exist1?(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- Date::jd_to_mjd
  #      Date::jd_to_mjd(jd)
  # ------------------------------------------------------------------------
  #      Convert a Julian Day Number to a Modified Julian Day Number.
  # 
  def self.jd_to_mjd(arg0)
  end

  # ------------------------------------------------- Date::commercial_to_jd
  #      Date::commercial_to_jd(y, w, d, ns=GREGORIAN)
  # ------------------------------------------------------------------------
  #      Convert a Commercial Date to a Julian Day Number.
  # 
  #      +y+, +w+, and +d+ are the (commercial) year, week of the year, and
  #      day of the week of the Commercial Date to convert. +sg+ specifies
  #      the Day of Calendar Reform.
  # 
  def self.commercial_to_jd(arg0, arg1, arg2, arg3, arg4, *rest)
  end

  # --------------------------------------------- Date::day_fraction_to_time
  #      Date::day_fraction_to_time(fr)
  # ------------------------------------------------------------------------
  #      Convert a fractional day +fr+ to [hours, minutes, seconds,
  #      fraction_of_a_second]
  # 
  def self.day_fraction_to_time(arg0)
  end

  def self.os?(arg0, arg1, *rest)
  end

  # ---------------------------------------------------- Date::ordinal_to_jd
  #      Date::ordinal_to_jd(y, d, sg=GREGORIAN)
  # ------------------------------------------------------------------------
  #      Convert an Ordinal Date to a Julian Day Number.
  # 
  #      +y+ and +d+ are the year and day-of-year to convert. +sg+ specifies
  #      the Day of Calendar Reform.
  # 
  #      Returns the corresponding Julian Day Number.
  # 
  def self.ordinal_to_jd(arg0, arg1, arg2, arg3, *rest)
  end

  def self.new3(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- Date::valid_jd?
  #      Date::valid_jd?(jd, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Is +jd+ a valid Julian Day Number?
  # 
  #      If it is, returns it. In fact, any value is treated as a valid
  #      Julian Day Number.
  # 
  def self.valid_jd?(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------------ Date::parse
  #      Date::parse(str='-4712-01-01', comp=false, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new Date object by parsing from a String, without
  #      specifying the format.
  # 
  #      +str+ is a String holding a date representation. +comp+ specifies
  #      whether to interpret 2-digit years as 19XX (>= 69) or 20XX (< 69);
  #      the default is not to. The method will attempt to parse a date from
  #      the String using various heuristics; see #_parse in date/format.rb
  #      for more details. If parsing fails, an ArgumentError will be
  #      raised.
  # 
  #      The default +str+ is '-4712-01-01'; this is Julian Day Number day
  #      0.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.parse(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- Date::mjd_to_jd
  #      Date::mjd_to_jd(mjd)
  # ------------------------------------------------------------------------
  #      Convert a Modified Julian Day Number to a Julian Day Number.
  # 
  def self.mjd_to_jd(arg0)
  end

  def self.existw?(arg0, arg1, *rest)
  end

  def self.valid_date?(arg0, arg1, arg2, arg3, arg4, *rest)
  end

  # -------------------------------------------------------- Date::jd_to_ajd
  #      Date::jd_to_ajd(jd, fr, of=0)
  # ------------------------------------------------------------------------
  #      Convert a (civil) Julian Day Number to an Astronomical Julian Day
  #      Number.
  # 
  #      +jd+ is the Julian Day Number to convert, and +fr+ is a fractional
  #      day. +of+ is the offset from UTC as a fraction of a day (defaults
  #      to 0).
  # 
  #      Returns the Astronomical Julian Day Number as a single numeric
  #      value.
  # 
  def self.jd_to_ajd(arg0, arg1, arg2, arg3, *rest)
  end

  def self.new2(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- Date::julian?
  #      Date::julian?(jd, sg)
  # ------------------------------------------------------------------------
  #      Does a given Julian Day Number fall inside the old-style (Julian)
  #      calendar?
  # 
  #      +jd+ is the Julian Day Number in question. +sg+ may be
  #      Date::GREGORIAN, in which case the answer is false; it may be
  #      Date::JULIAN, in which case the answer is true; or it may a number
  #      representing the Day of Calendar Reform. Date::ENGLAND and
  #      Date::ITALY are two possible such days.
  # 
  def self.julian?(arg0, arg1)
  end

  # ------------------------------------------------------------ Date::civil
  #      Date::civil(y=-4712, m=1, d=1, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new Date object for the Civil Date specified by year +y+,
  #      month +m+, and day-of-month +d+.
  # 
  #      +m+ and +d+ can be negative, in which case they count backwards
  #      from the end of the year and the end of the month respectively. No
  #      wraparound is performed, however, and invalid values cause an
  #      ArgumentError to be raised. can be negative
  # 
  #      +y+ defaults to -4712, +m+ to 1, and +d+ to 1; this is Julian Day
  #      Number day 0.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.civil(arg0, arg1, *rest)
  end

  def self.leap?(arg0)
  end

  def self.new0(arg0, arg1, *rest)
  end

  # ------------------------------------------------- Date::jd_to_commercial
  #      Date::jd_to_commercial(jd, sg=GREGORIAN)
  # ------------------------------------------------------------------------
  #      Convert a Julian Day Number to a Commercial Date
  # 
  #      +jd+ is the Julian Day Number to convert. +sg+ specifies the Day of
  #      Calendar Reform.
  # 
  #      Returns the corresponding Commercial Date as [commercial_year,
  #      week_of_year, day_of_week]
  # 
  def self.jd_to_commercial(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------------ Date::_load
  #      Date::_load(str)
  # ------------------------------------------------------------------------
  #      Load from Marshall format.
  # 
  def self._load(arg0)
  end

  # --------------------------------------------------------- Date::jd_to_ld
  #      Date::jd_to_ld(jd)
  # ------------------------------------------------------------------------
  #      Convert a Julian Day Number to the number of days since the
  #      adoption of the Gregorian Calendar (in Italy).
  # 
  def self.jd_to_ld(arg0)
  end

  def self.exist2?(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Date::new
  #      Date::new(ajd=0, of=0, sg=ITALY)
  # ------------------------------------------------------------------------
  #      *NOTE* this is the documentation for the method new!(). If you are
  #      reading this as the documentation for new(), that is because rdoc
  #      doesn't fully support the aliasing of the initialize() method.
  #      new() is in fact an alias for #civil(): read the documentation for
  #      that method instead.
  # 
  #      Create a new Date object.
  # 
  #      +ajd+ is the Astronomical Julian Day Number. +of+ is the offset
  #      from UTC as a fraction of a day. Both default to 0.
  # 
  #      +sg+ specifies the Day of Calendar Reform to use for this Date
  #      object.
  # 
  #      Using one of the factory methods such as Date::civil is generally
  #      easier and safer.
  # 
  def self.new(arg0, arg1, *rest)
  end

  # ------------------------------------------------------ Date::jd_to_civil
  #      Date::jd_to_civil(jd, sg=GREGORIAN)
  # ------------------------------------------------------------------------
  #      Convert a Julian Day Number to a Civil Date. +jd+ is the Julian Day
  #      Number. +sg+ specifies the Day of Calendar Reform.
  # 
  #      Returns the corresponding [year, month, day_of_month] as a
  #      three-element array.
  # 
  def self.jd_to_civil(arg0, arg1, arg2, *rest)
  end

  # ----------------------------------------------------------- Date::_parse
  #      Date::_parse(str, comp=false)
  # ------------------------------------------------------------------------
  #      (no description...)
  def self._parse(arg0, arg1, arg2, *rest)
  end

  # ----------------------------------------------------- Date::valid_civil?
  #      Date::valid_civil?(y, m, d, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Do year +y+, month +m+, and day-of-month +d+ make a valid Civil
  #      Date? Returns the corresponding Julian Day Number if they do, nil
  #      if they don't.
  # 
  #      +m+ and +d+ can be negative, in which case they count backwards
  #      from the end of the year and the end of the month respectively. No
  #      wraparound is performed, however, and invalid values cause an
  #      ArgumentError to be raised. A date falling in the period skipped in
  #      the Day of Calendar Reform adjustment is not valid.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.valid_civil?(arg0, arg1, arg2, arg3, arg4, *rest)
  end

  # --------------------------------------------------------------- Date::jd
  #      Date::jd(jd=0, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new Date object from a Julian Day Number.
  # 
  #      +jd+ is the Julian Day Number; if not specified, it defaults to 0.
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.jd(arg0, arg1, *rest)
  end

  # --------------------------------------------------------- Date::ld_to_jd
  #      Date::ld_to_jd(ld)
  # ------------------------------------------------------------------------
  #      Convert a count of the number of days since the adoption of the
  #      Gregorian Calendar (in Italy) to a Julian Day Number.
  # 
  def self.ld_to_jd(arg0)
  end

  # ----------------------------------------------------- Date::julian_leap?
  #      Date::julian_leap?(y)
  # ------------------------------------------------------------------------
  #      Is a year a leap year in the Julian calendar?
  # 
  #      All years divisible by 4 are leap years in the Julian calendar.
  # 
  def self.julian_leap?(arg0)
  end

  # ------------------------------------------------------ Date::civil_to_jd
  #      Date::civil_to_jd(y, m, d, sg=GREGORIAN)
  # ------------------------------------------------------------------------
  #      Convert a Civil Date to a Julian Day Number. +y+, +m+, and +d+ are
  #      the year, month, and day of the month. +sg+ specifies the Day of
  #      Calendar Reform.
  # 
  #      Returns the corresponding Julian Day Number.
  # 
  def self.civil_to_jd(arg0, arg1, arg2, arg3, arg4, *rest)
  end

  # --------------------------------------------- Date::time_to_day_fraction
  #      Date::time_to_day_fraction(h, min, s)
  # ------------------------------------------------------------------------
  #      Convert an +h+ hour, +min+ minutes, +s+ seconds period to a
  #      fractional day.
  # 
  def self.time_to_day_fraction(arg0, arg1, arg2)
  end

  def self.ns?(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- Date::_strptime
  #      Date::_strptime(str, fmt='%F')
  # ------------------------------------------------------------------------
  #      (no description...)
  def self._strptime(arg0, arg1, arg2, *rest)
  end

  # --------------------------------------------------- Date::valid_ordinal?
  #      Date::valid_ordinal?(y, d, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Do the year +y+ and day-of-year +d+ make a valid Ordinal Date?
  #      Returns the corresponding Julian Day Number if they do, or nil if
  #      they don't.
  # 
  #      +d+ can be a negative number, in which case it counts backwards
  #      from the end of the year (-1 being the last day of the year). No
  #      year wraparound is performed, however, so valid values of +d+ are
  #      -365 .. -1, 1 .. 365 on a non-leap-year, -366 .. -1, 1 .. 366 on a
  #      leap year. A date falling in the period skipped in the Day of
  #      Calendar Reform adjustment is not valid.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.valid_ordinal?(arg0, arg1, arg2, arg3, *rest)
  end

  def self.neww(arg0, arg1, *rest)
  end

  def self.exist?(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- Date::ajd_to_jd
  #      Date::ajd_to_jd(ajd, of=0)
  # ------------------------------------------------------------------------
  #      Convert an Astronomical Julian Day Number to a (civil) Julian Day
  #      Number.
  # 
  #      +ajd+ is the Astronomical Julian Day Number to convert. +of+ is the
  #      offset from UTC as a fraction of a day (defaults to 0).
  # 
  #      Returns the (civil) Julian Day Number as [day_number, fraction]
  #      where +fraction+ is always 1/2.
  # 
  def self.ajd_to_jd(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------- Date::gregorian?
  #      Date::gregorian?(jd, sg)
  # ------------------------------------------------------------------------
  #      Does a given Julian Day Number fall inside the new-style
  #      (Gregorian) calendar?
  # 
  #      The reverse of self.os? See the documentation for that method for
  #      more details.
  # 
  def self.gregorian?(arg0, arg1)
  end

  # ------------------------------------------------------------ Date::today
  #      Date::today(sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new Date object representing today.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.today(arg0, arg1, *rest)
  end

  # ------------------------------------------------ Date::valid_commercial?
  #      Date::valid_commercial?(y, w, d, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Do year +y+, week-of-year +w+, and day-of-week +d+ make a valid
  #      Commercial Date? Returns the corresponding Julian Day Number if
  #      they do, nil if they don't.
  # 
  #      Monday is day-of-week 1; Sunday is day-of-week 7.
  # 
  #      +w+ and +d+ can be negative, in which case they count backwards
  #      from the end of the year and the end of the week respectively. No
  #      wraparound is performed, however, and invalid values cause an
  #      ArgumentError to be raised. A date falling in the period skipped in
  #      the Day of Calendar Reform adjustment is not valid.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.valid_commercial?(arg0, arg1, arg2, arg3, arg4, *rest)
  end

  def self.new!(arg0, arg1, *rest)
  end

  def self.zone_to_diff(arg0)
  end

  # ------------------------------------------------------- Date::commercial
  #      Date::commercial(y=1582, w=41, d=5, sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new Date object for the Commercial Date specified by year
  #      +y+, week-of-year +w+, and day-of-week +d+.
  # 
  #      Monday is day-of-week 1; Sunday is day-of-week 7.
  # 
  #      +w+ and +d+ can be negative, in which case they count backwards
  #      from the end of the year and the end of the week respectively. No
  #      wraparound is performed, however, and invalid values cause an
  #      ArgumentError to be raised.
  # 
  #      +y+ defaults to 1582, +w+ to 41, and +d+ to 5, the Day of Calendar
  #      Reform for Italy and the Catholic countries.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  def self.commercial(arg0, arg1, *rest)
  end

  # ------------------------------------------------------- Date::jd_to_wday
  #      Date::jd_to_wday(jd)
  # ------------------------------------------------------------------------
  #      Convert a Julian Day Number to the day of the week.
  # 
  #      Sunday is day-of-week 0; Saturday is day-of-week 6.
  # 
  def self.jd_to_wday(arg0)
  end

  # --------------------------------------------------------- Date::strptime
  #      Date::strptime(str='-4712-01-01', fmt='%F', sg=ITALY)
  # ------------------------------------------------------------------------
  #      Create a new Date object by parsing from a String according to a
  #      specified format.
  # 
  #      +str+ is a String holding a date representation. +fmt+ is the
  #      format that the date is in. See date/format.rb for details on
  #      supported formats.
  # 
  #      The default +str+ is '-4712-01-01', and the default +fmt+ is '%F',
  #      which means Year-Month-Day_of_Month. This gives Julian Day Number
  #      day 0.
  # 
  #      +sg+ specifies the Day of Calendar Reform.
  # 
  #      An ArgumentError will be raised if +str+ cannot be parsed.
  # 
  def self.strptime(arg0, arg1, *rest)
  end

  def self.new1(arg0, arg1, *rest)
  end

  # ------------------------------------------------------ Date::valid_time?
  #      Date::valid_time?(h, min, s)
  # ------------------------------------------------------------------------
  #      Do hour +h+, minute +min+, and second +s+ constitute a valid time?
  # 
  #      If they do, returns their value as a fraction of a day. If not,
  #      returns nil.
  # 
  #      The 24-hour clock is used. Negative values of +h+, +min+, and +sec+
  #      are treating as counting backwards from the end of the next larger
  #      unit (e.g. a +min+ of -2 is treated as 58). No wraparound is
  #      performed.
  # 
  def self.valid_time?(arg0, arg1, arg2)
  end

  # ------------------------------------------------------ Date::ajd_to_amjd
  #      Date::ajd_to_amjd(ajd)
  # ------------------------------------------------------------------------
  #      Convert an Astronomical Julian Day Number to an Astronomical
  #      Modified Julian Day Number.
  # 
  def self.ajd_to_amjd(arg0)
  end

  def self.exist3?(arg0, arg1, *rest)
  end

  def self.yaml_tag_subclasses?
  end

  # --------------------------------------------------------- Date#gregorian
  #      gregorian()
  # ------------------------------------------------------------------------
  #      Create a copy of this Date object that always uses the Gregorian
  #      Calendar.
  # 
  def gregorian
  end

  # ------------------------------------------------------------- Date#_dump
  #      _dump(limit)
  # ------------------------------------------------------------------------
  #      Dump to Marshal format.
  # 
  def _dump(arg0)
  end

  # ---------------------------------------------------------------- Date#ld
  #      ld()
  # ------------------------------------------------------------------------
  #      Get the date as the number of days since the Day of Calendar Reform
  #      (in Italy and the Catholic countries).
  # 
  def ld(arg0, arg1, *rest)
  end

  # --------------------------------------------------------------- Date#day
  #      day()
  # ------------------------------------------------------------------------
  #      Alias for #mday
  # 
  def day
  end

  # ------------------------------------------------------------- Date#cweek
  #      cweek()
  # ------------------------------------------------------------------------
  #      Get the commercial week of the year of this date.
  # 
  def cweek
  end

  # ------------------------------------------------------ Date#day_fraction
  #      day_fraction()
  # ------------------------------------------------------------------------
  #      Get any fractional day part of the date.
  # 
  def day_fraction(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Date#yday
  #      yday()
  # ------------------------------------------------------------------------
  #      Get the day-of-the-year of this date.
  # 
  #      January 1 is day-of-the-year 1
  # 
  def yday
  end

  def newsg(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Date#to_s
  #      to_s()
  # ------------------------------------------------------------------------
  #      Return the date as a human-readable string.
  # 
  #      The format used is YYYY-MM-DD.
  # 
  def to_s
  end

  # --------------------------------------------------------------- Date#ajd
  #      ajd()
  # ------------------------------------------------------------------------
  #      Get the date as an Astronomical Julian Day Number.
  # 
  def ajd
  end

  # ------------------------------------------------------------- Date#start
  #      start()
  # ------------------------------------------------------------------------
  #      When is the Day of Calendar Reform for this Date object?
  # 
  def start
  end

  # ---------------------------------------------------------- Date#strftime
  #      strftime(fmt='%F')
  # ------------------------------------------------------------------------
  #      (no description...)
  def strftime(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Date#england
  #      england()
  # ------------------------------------------------------------------------
  #      Create a copy of this Date object that uses the English/Colonial
  #      Day of Calendar Reform.
  # 
  def england
  end

  def os?(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Date#step
  #      step(limit, step=1) {|date| ...}
  # ------------------------------------------------------------------------
  #      Step the current date forward +step+ days at a time (or backward,
  #      if +step+ is negative) until we reach +limit+ (inclusive), yielding
  #      the resultant date at each step.
  # 
  def step(arg0, arg1, arg2, *rest)
  end

  # ----------------------------------------------------------------- Date#+
  #      +(n)
  # ------------------------------------------------------------------------
  #      Return a new Date object that is +n+ days later than the current
  #      one.
  # 
  #      +n+ may be a negative value, in which case the new Date is earlier
  #      than the current one; however, #-() might be more intuitive.
  # 
  #      If +n+ is not a Numeric, a TypeError will be thrown. In particular,
  #      two Dates cannot be added to each other.
  # 
  def +(arg0)
  end

  # -------------------------------------------------------------- Date#year
  #      year()
  # ------------------------------------------------------------------------
  #      Get the year of this date.
  # 
  def year
  end

  # -------------------------------------------------------------- Date#upto
  #      upto(max) {|date| ...}
  # ------------------------------------------------------------------------
  #      Step forward one day at a time until we reach +max+ (inclusive),
  #      yielding each date as we go.
  # 
  def upto(arg0)
  end

  # --------------------------------------------------------- Date#new_start
  #      new_start(sg=self.class::ITALY)
  # ------------------------------------------------------------------------
  #      Create a copy of this Date object using a new Day of Calendar
  #      Reform.
  # 
  def new_start(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Date#asctime
  #      asctime()
  # ------------------------------------------------------------------------
  #      alias_method :format, :strftime
  # 
  # 
  #      (also known as ctime)
  def asctime
  end

  # ------------------------------------------------------------- Date#ctime
  #      ctime()
  # ------------------------------------------------------------------------
  #      Alias for #asctime
  # 
  def ctime
  end

  def taguri
  end

  # ----------------------------------------------------------------- Date#-
  #      -(x)
  # ------------------------------------------------------------------------
  #      If +x+ is a Numeric value, create a new Date object that is +x+
  #      days earlier than the current one.
  # 
  #      If +x+ is a Date, return the number of days between the two dates;
  #      or, more precisely, how many days later the current date is than
  #      +x+.
  # 
  #      If +x+ is neither Numeric nor a Date, a TypeError is raised.
  # 
  def -(arg0)
  end

  # -------------------------------------------------------------- Date#eql?
  #      eql?(other)
  # ------------------------------------------------------------------------
  #      Is this Date equal to +other+?
  # 
  #      +other+ must both be a Date object, and represent the same date.
  # 
  def eql?(arg0)
  end

  # --------------------------------------------------------------- Date#mon
  #      mon()
  # ------------------------------------------------------------------------
  #      Get the month of this date.
  # 
  #      January is month 1.
  # 
  # 
  #      (also known as month)
  def mon
  end

  # ----------------------------------------------------------- Date#julian?
  #      julian?()
  # ------------------------------------------------------------------------
  #      Is the current date old-style (Julian Calendar)?
  # 
  def julian?(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Date#next
  #      next()
  # ------------------------------------------------------------------------
  #      Return a new Date one day after this one.
  # 
  # 
  #      (also known as succ)
  def next
  end

  # ------------------------------------------------------------- Date#leap?
  #      leap?()
  # ------------------------------------------------------------------------
  #      Is this a leap year?
  # 
  def leap?(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- Date#cwday
  #      cwday()
  # ------------------------------------------------------------------------
  #      Get the commercial day of the week of this date. Monday is
  #      commercial day-of-week 1; Sunday is commercial day-of-week 7.
  # 
  def cwday
  end

  # -------------------------------------------------------------- Date#amjd
  #      amjd()
  # ------------------------------------------------------------------------
  #      Get the date as an Astronomical Modified Julian Day Number.
  # 
  def amjd(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Date#inspect
  #      inspect()
  # ------------------------------------------------------------------------
  #      Return internal object state as a programmer-readable string.
  # 
  def inspect
  end

  def taguri=(arg0)
  end

  # ---------------------------------------------------------------- Date#jd
  #      jd()
  # ------------------------------------------------------------------------
  #      Get the date as a Julian Day Number.
  # 
  def jd(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Date#mday
  #      mday()
  # ------------------------------------------------------------------------
  #      Get the day-of-the-month of this date.
  # 
  # 
  #      (also known as day)
  def mday
  end

  # ---------------------------------------------------------------- Date#<<
  #      <<(n)
  # ------------------------------------------------------------------------
  #      Return a new Date object that is +n+ months earlier than the
  #      current one.
  # 
  #      If the day-of-the-month of the current Date is greater than the
  #      last day of the target month, the day-of-the-month of the returned
  #      Date will be the last day of the target month.
  # 
  def <<(arg0)
  end

  # -------------------------------------------------------------- Date#succ
  #      succ()
  # ------------------------------------------------------------------------
  #      Alias for #next
  # 
  def succ
  end

  # ------------------------------------------------------------ Date#julian
  #      julian()
  # ------------------------------------------------------------------------
  #      Create a copy of this Date object that always uses the Julian
  #      Calendar.
  # 
  def julian
  end

  # ------------------------------------------------------------ Date#cwyear
  #      cwyear()
  # ------------------------------------------------------------------------
  #      Get the commercial year of this date. See *Commercial* *Date* in
  #      the introduction for how this differs from the normal year.
  # 
  def cwyear
  end

  # ---------------------------------------------------------------- Date#>>
  #      >>(n)
  # ------------------------------------------------------------------------
  #      Return a new Date object that is +n+ months later than the current
  #      one.
  # 
  #      If the day-of-the-month of the current Date is greater than the
  #      last day of the target month, the day-of-the-month of the returned
  #      Date will be the last day of the target month.
  # 
  def >>(arg0)
  end

  # ------------------------------------------------------------ Date#downto
  #      downto(min) {|date| ...}
  # ------------------------------------------------------------------------
  #      Step backward one day at a time until we reach +min+ (inclusive),
  #      yielding each date as we go.
  # 
  def downto(arg0)
  end

  # -------------------------------------------------------------- Date#hash
  #      hash()
  # ------------------------------------------------------------------------
  #      Calculate a hash value for this date.
  # 
  def hash
  end

  # ----------------------------------------------------------- Date#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

  def ns?(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- Date#gregorian?
  #      gregorian?()
  # ------------------------------------------------------------------------
  #      Is the current date new-style (Gregorian Calendar)?
  # 
  def gregorian?(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Date#wday
  #      wday()
  # ------------------------------------------------------------------------
  #      Get the week day of this date. Sunday is day-of-week 0; Saturday is
  #      day-of-week 6.
  # 
  def wday(arg0, arg1, *rest)
  end

  # --------------------------------------------------------------- Date#mjd
  #      mjd()
  # ------------------------------------------------------------------------
  #      Get the date as a Modified Julian Day Number.
  # 
  def mjd(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- Date#italy
  #      italy()
  # ------------------------------------------------------------------------
  #      Create a copy of this Date object that uses the Italian/Catholic
  #      Day of Calendar Reform.
  # 
  def italy
  end

  # ------------------------------------------------------------- Date#month
  #      month()
  # ------------------------------------------------------------------------
  #      Alias for #mon
  # 
  def month
  end

  # --------------------------------------------------------------- Date#<=>
  #      <=>(other)
  # ------------------------------------------------------------------------
  #      Compare this date with another date.
  # 
  #      +other+ can also be a Numeric value, in which case it is
  #      interpreted as an Astronomical Julian Day Number.
  # 
  #      Comparison is by Astronomical Julian Day Number, including
  #      fractional days. This means that both the time and the timezone
  #      offset are taken into account when comparing two DateTime
  #      instances. When comparing a DateTime instance with a Date instance,
  #      the time of the latter will be considered as falling on midnight
  #      UTC.
  # 
  def <=>(arg0)
  end

  # --------------------------------------------------------------- Date#===
  #      ===(other)
  # ------------------------------------------------------------------------
  #      The relationship operator for Date.
  # 
  #      Compares dates by Julian Day Number. When comparing two DateTime
  #      instances, or a DateTime with a Date, the instances will be
  #      regarded as equivalent if they fall on the same date in local time.
  # 
  def ===(arg0)
  end

  def sg(arg0, arg1, *rest)
  end

end
