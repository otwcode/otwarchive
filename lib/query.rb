# restart the server or touch $RAILS_ROOT/tmp/restart.txt if you change this file.

module Query

  WORK_FIELDS = %w{author title language tag}
  WORK_INDEXES = WORK_FIELDS + %w{words hits date}
  
  # this is used to take a full text query from the small search box
  # like "author: astolat words: > 1000" 
  # and turn it into a hash that can be put into separate boxes on the full search page
  def Query.standardize(query)
    return unless query[:text]
    # change something: to @something so we know a section ends when the next section starts
    for string in WORK_INDEXES
      query[:text] = query[:text].sub(/#{string}:/i, "@#{string} ")
    end
    for string in WORK_INDEXES
      match = query[:text].match(/@#{string} ([^@]*)/)
      if match
        query[:text] = match.pre_match + match.post_match
        query[string.to_sym] = match[1]
      end
    end
    query.each { |k, v| query[k] = v.strip }
  end
  
  # transform the full search page into
  # a search string plus an attributes hash for sphinx
  def Query.split_query(query)
    with = {}
    errors = []
    text = query[:text] || ""
    for string in WORK_FIELDS
      text = (text + " @" + string + " " + query[string.to_sym]) unless query[string.to_sym].blank?
    end
    for string in %w{word hit} do
      unless query[string.pluralize.to_sym].blank?
        match = query[string.pluralize.to_sym].match(/^([<>]*)\s*([\d,. -]+)\s*$/)
        if match
          with[(string + "_count").to_sym] = Query.numerical_range(match[1], match[2]) 
        else
          errors<<"bad #{string.pluralize} format (ignored)"
        end
      end
    end
    unless query[:date].blank?
      match = query[:date].match(/^([<>]*)\s*([\d -]+)\s*(year|week|month|day|hour)s?(\s*ago)?s*$/)
      if match
        with[:revised_at] = Query.time_range(match[1], match[2], match[3])
      else
        errors<<"bad date format (ignored)"
      end
    end
    return [text.strip, with, errors]
  end
  
  # create numerical range from operand and string
  # operand can be "<", ">" or ""
  # string must be an integer unless operand is ""
  # in which case it can be two numbers connected by "-"
  # punctuation such as , and . are ignored (10.000 == 10,000 == 10000)
  def self.numerical_range(operand, string)
    string = string.gsub(/[,.]/, "")
    case operand
      when "<"
        Range.new(0, string.to_i - 1)
      when ">"
        Range.new(string.to_i + 1, 1000000)
      when ""
        match = string.match(/-/)
        if match
          match.pre_match.to_i .. match.post_match.to_i
        else
          string.to_i
        end
    end
  end
  
  # create time range from operand, amount and period
  # period must be one known by time_from_string
  def self.time_range(operand, amount, period)
    case operand
      when "<"
        time = Query.time_from_string(amount, period)
        time .. Time.now
      when ">"
        time = Query.time_from_string(amount, period)
        Time.at(0) .. time
      when ""
        match = amount.match(/-/)
        if match
          time1 = Query.time_from_string(match.pre_match, period)
          time2 = Query.time_from_string(match.post_match, period)
          time2 .. time1
        else
          raise "can't determine time range from one number"
        end
    end
  end

  # helper method to create times from two strings
  def self.time_from_string(amount, period)
    case period
      when /year/
        amount.to_i.year.ago
      when /month/
        amount.to_i.month.ago
      when /week/
        amount.to_i.week.ago
      when /day/
        amount.to_i.day.ago
      when /hour/
        amount.to_i.hour.ago
      else
        raise "unknown period: " + period
    end
  end
    
end
