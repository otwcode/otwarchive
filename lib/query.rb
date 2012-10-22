# restart the server or touch $RAILS_ROOT/tmp/restart.txt if you change this file.

module Query

  WORK_FIELDS = %w{author title language tag}
  BOOKMARK_FIELDS = %w{tag indirect notes bookmarker}
  PEOPLE_FIELDS = %w{id name icon_alt_text description}
  ALL_FIELDS = (WORK_FIELDS + BOOKMARK_FIELDS + PEOPLE_FIELDS).uniq
  ALL_INDEXES = ALL_FIELDS + %w{words hits date rec canonical recced bookmarked}
  
  def Query.search(klass, query, page)
    return nil, klass.paginate(:page => page)
  end

  # this does the actual search on the class given a standardized query hash
  def Query.search_with_sphinx(klass, query, page)
    search_string, with_hash, query_errors = Query.split_query(query)
    # set pagination and extend mode
    options = {
      :per_page => ArchiveConfig.ITEMS_PER_PAGE,
      :max_matches => ArchiveConfig.SEARCH_RESULTS_MAX,
      :page => page,
      :match_mode => :extended,
      :hidden_by_admin => false
      }
    # attribute restrictions
    if klass == Work
      if User.current_user.nil?
        with_hash.update({:posted => true, :restricted => false})
      else
        with_hash.update({:posted => true})
        ## TODO add personal filters here
      end
    end
    options[:with] = with_hash
    return query_errors, klass.search(search_string, options)
  end

  # this is used to standardize a query, specifically, moving things
  # like "author: astolat words: >1,000" to :author => {"astolat"}, :words => {"> 1000"}
  def Query.standardize(query)
    Rails.logger.debug "original query: #{query.to_s}"
    query[:text] = "" unless query[:text]
    # change something: to @something so we know a section ends when the next section starts
    for string in ALL_INDEXES
      query[:text] = query[:text].sub(/#{string}:/i, "@#{string} ")
    end
    # remove a single multiple-field search operator of the form (i.e. leave it in :text)
    #   (field1,field2): search string
    match = query[:text].match(/\(\S+?\,\S+?\): ([^@]*)/)
    if match
      query[:group] = match[0]
      query[:text] = match.pre_match + match.post_match
    end
    for string in ALL_INDEXES
      match = query[:text].match(/@#{string} ([^@]*)/)
      if match
        query[:text] = match.pre_match + match.post_match
        query[string.to_sym] = match[1]
      end
    end
    # add multiple-field search operator back at the end
    if query[:group]
      query[:text] = query[:text] + query.delete(:group)
    end
    query.each { |k, v| query[k] = v.strip }
    query.delete_if { |k, v| v.blank? }
    # in rails 3, a query with < or > will get encoded, unencode them again
    # also, remove punctuation such as , and . (10.000 == 10,000 == 10000)
    for string in %w{word hit bookmark date} do
      sym = string.pluralize.to_sym unless string == "date"
      sym = string.to_sym if string == "date"
      query[sym] = query[sym].gsub("&gt;", ">").gsub("&lt;", "<").gsub(/[,.]/, "") if query[sym]
    end
    return query
  end

  # transform the query into
  # a search string plus an attributes hash for sphinx
  def Query.split_query(query={})
    with = {}
    errors = []
    text = query[:text] || ""
    # transform
    #   (field1,field2): search string
    # into sphinx's multiple-field search operator
    #   @(field1,field2) search string
    match = text.match(/(\(\S+?\,\S+?\)):( .+)$/)
    if match
      text = match.pre_match + match.post_match
      text = text + "@" + match[1]  + match[2]
    end
    for string in ALL_FIELDS
      text = (text + " @" + string + " " + query[string.to_sym]) unless query[string.to_sym].blank?
    end
    text = (text + " @type " + query[:type]) unless query[:type].blank?
    for string in %w{word hit bookmark} do
      sym = string.pluralize.to_sym
      unless query[sym].blank?
        match = query[sym].match(/^([<>]*)\s*([\d,. -]+)\s*$/)
        if match
          with[(string + "_count").to_sym] = Query.numerical_range(match[1], match[2])
        else
          errors<<"bad #{string.pluralize} format (ignored)"
        end
      end
    end
    with[:rec] = true if query[:rec]
    with[:canonical] = true if query[:canonical]
    with[:recced] = true if query[:recced]
    with[:complete] = true if query[:complete]
    with[:bookmarker] = Range.new(1,1000000) if query[:bookmarked]
    unless query[:date].blank?
      match = query[:date].match(/^([<>]*)\s*([\d -]+)\s*(year|week|month|day|hour)s?(\s*ago)?s*$/)
      if match
        with[:revised_at] = Query.time_range(match[1], match[2], match[3])
      else
        errors<<"bad date format (ignored)"
      end
    end
    # replace AND/OR/NOT with sphinx symbols
    text = text.gsub(/AND/, "").gsub(/OR/, "|").gsub(/NOT\s+/, "-")
    # escape slash from sphinx quorum operators
    text = text.gsub('/', '\\/')
    Rails.logger.debug "Search string: #{text}"
    Rails.logger.debug "Search attribs: #{with}"
    Rails.logger.debug "Search errors: #{errors}"
    return [text.strip, with, errors]
  end

  # create numerical range from operand and string
  # operand can be "<", ">" or ""
  # string must be an integer unless operand is ""
  # in which case it can be two numbers connected by "-"
  def self.numerical_range(operand, string)
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
          Query.range_from_string(amount, period)
          # raise "can't determine time range from one number"
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

  # Generate a range based on one number
  # Interval is based on period used, ie 1 month ago = range from beginning to end of month
  def self.range_from_string(amount, period)
    case period
      when /year/
        a = amount.to_i.year.ago.beginning_of_year
        a..a.end_of_year
      when /month/
        a = amount.to_i.month.ago.beginning_of_month
        a..a.end_of_month
      when /week/
        a = amount.to_i.week.ago.beginning_of_week
        a..a.end_of_week
      when /day/
        a = amount.to_i.day.ago.beginning_of_day
        a..a.end_of_day
      when /hour/
        a = amount.to_i.hour.ago.change(:min => 0, :sec => 0, :usec => 0)
        a..(a + 60.minutes)
      else
        raise "unknown period: " + period
    end
  end

end
