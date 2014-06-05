class Search < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :name
  validates_presence_of :options
  
  serialize :options, Hash
  
  def self.serialized_options(*args)
    args.each do |method_name|
      eval "
        def #{method_name}
          (self.options || {})[:#{method_name}]
        end
        def #{method_name}=(value)
          self.options ||= {}
          self.options[:#{method_name}] = value
        end
      "
    end
  end
  
  def self.range_to_search(option)
    option.gsub!("&gt;", ">")
    option.gsub!("&lt;", "<")
    match = option.match(/^([<>]*)\s*([\d -]+)\s*(year|week|month|day|hour)s?(\s*ago)?s*$/)
    range = {}
    if match
      range = time_range(match[1], match[2], match[3])
    else
      match = option.match(/^([<>]*)\s*([\d,. -]+)\s*$/)
      if match
        range = numerical_range(match[1], match[2].gsub(",", ""))
      end
    end
    range
  end
  
  # create numerical range from operand and string
  # operand can be "<", ">" or ""
  # string must be an integer unless operand is ""
  # in which case it can be two numbers connected by "-"
  def self.numerical_range(operand, string)
    case operand
    when "<"
      { lt: string.to_i }
    when ">"
      { gt: string.to_i }
    when ""
      match = string.match(/-/)
      if match
        { gte: match.pre_match.to_i, lte: match.post_match.to_i }
      else
        { gte: string.to_i, lte: string.to_i }
      end
    end
  end

  # create time range from operand, amount and period
  # period must be one known by time_from_string
  def self.time_range(operand, amount, period)
    case operand
    when "<"
      time = time_from_string(amount, period)
      { gt: time }
    when ">"
      time = time_from_string(amount, period)
      { lt: time }
    when ""
      match = amount.match(/-/)
      if match
        time1 = time_from_string(match.pre_match, period)
        time2 = time_from_string(match.post_match, period)
        { gte: time2, lte: time1 }
      else
        range_from_string(amount, period)
      end
    end
  end

  # helper method to create times from two strings
  def self.time_from_string(amount, period)
    amount.to_i.send(period).ago
  end

  # Generate a range based on one number
  # Interval is based on period used, ie 1 month ago = range from beginning to end of month
  def self.range_from_string(amount, period)
    case period
    when /year/
      a = amount.to_i.year.ago.beginning_of_year
      a2 = a.end_of_year
    when /month/
      a = amount.to_i.month.ago.beginning_of_month
      a2 = a.end_of_month
    when /week/
      a = amount.to_i.week.ago.beginning_of_week
      a2 = a.end_of_week
    when /day/
      a = amount.to_i.day.ago.beginning_of_day
      a2 = a.end_of_day
    when /hour/
      a = amount.to_i.hour.ago.change(:min => 0, :sec => 0, :usec => 0)
      a2 = (a + 60.minutes)
    else
      raise "unknown period: " + period
    end
    { gte: a, lte: a2 }
  end
  
  # Only escape if it isn't already escaped
  def escape_slashes(word)
    word = word.gsub(/([^\\])\//) { |s| $1 + '\\/' }
  end
  
  def escape_reserved_characters(word)
    word = escape_slashes(word)
    word.gsub!('!', '\\!')
    word.gsub!('+', '\\+')
    word.gsub!('-', '\\-')
    word.gsub!('?', '\\?')
    word.gsub!("~", '\\~')
    word.gsub!("(", '\\(')
    word.gsub!(")", '\\)')
    word.gsub!("[", '\\[')
    word.gsub!("]", '\\]')
    word.gsub!(':', '\\:')
    word
  end
  
end
