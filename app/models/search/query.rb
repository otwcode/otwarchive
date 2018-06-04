class Query

  attr_reader :options

  # Options: page, per_page
  def initialize(options={})
    @options = HashWithIndifferentAccess.new(options)
  end

  def search
    # ES UPGRADE TRANSITION #
    # Change $new_elasticsearch to $elasticsearch
    $new_elasticsearch.search(
      index: index_name,
      type: document_type,
      body: generated_query
    )
  end

  def search_results
    response = search
    QueryResult.new(klass, response, { page: page, per_page: per_page })
  end

  # Perform a count query based on the given options
  def count
    $new_elasticsearch.count(
      index: index_name,
      body: { query: generated_query[:query] }
    )['count']
  end

  # Sort by relevance by default, override in subclasses as necessary
  def sort
    { "_score" => { order: "desc" }}
  end

  # Search query with filters
  def generated_query
    q = {
      query: filtered_query,
      size: per_page,
      from: pagination_offset,
      sort: sort
    }
    if aggregations.present?
      q.merge!(aggregations)
    end
    q
  end

  # Combine the filters and queries
  def filtered_query
    make_bool(
      must: queries, # required, score calculated
      filter: filters, # required, score ignored
      must_not: exclusion_filters # disallowed, score ignored
    )
  end

  # Define specifics in subclasses

  def filters
    @filters
  end

  def term_filter(field, value, options={})
    { term: options.merge(field => value) }
  end

  def terms_filter(field, value, options={})
    { terms: options.merge(field => value) }
  end

  # A filter used to match all words in a particular field, most frequently
  # used for matching non-existent tags. The match query doesn't allow
  # negation/or/and/wildcards, so it should only be used on fields where the
  # users are expected to enter, e.g. canonical tags.
  def match_filter(field, value, options = {})
    { match: { field => { query: value, operator: "and" }.merge(options) } }
  end

  # Set the score equal to the value of a field. The optional value "missing"
  # determines what score value should be used if the specified field is
  # missing from a document.
  def field_value_score(field, missing: 0)
    {
      function_score: {
        field_value_factor: {
          field: field,
          missing: missing
        }
      }
    }
  end

  def bool_value(str)
    %w(true 1 T).include?(str.to_s)
  end

  def exclusion_filters
    @exclusion_filters
  end

  def queries
  end

  def aggregations
  end

  def index_name
  end

  def document_type
  end

  def per_page
    options[:per_page] || ArchiveConfig.ITEMS_PER_PAGE
  end

  # Example: if the limit is 3 results, and we're displaying 2 per page,
  # disallow pages beyond page 2.
  def page
    [
      options[:page] || 1,
      (ArchiveConfig.MAX_SEARCH_RESULTS / per_page.to_f).ceil
    ].min
  end

  def pagination_offset
    (page * per_page) - per_page
  end

  # Only escape if it isn't already escaped
  def escape_slashes(word)
    word.gsub(/([^\\])\//) { |s| $1 + '\\/' }
  end

  def escape_reserved_characters(word)
    word = escape_slashes(word)
    word.gsub!('!', '\\!')
    word.gsub!('+', '\\\\+')
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

  def split_query_text_phrases(fieldname, text)
    str = ""
    return str if text.blank?
    text.split(",").map(&:squish).each do |phrase|
      str << " #{fieldname}:\"#{phrase}\""
    end
    str
  end

  def split_query_text_words(fieldname, text)
    str = ""
    return str if text.blank?
    text.split(" ").each do |word|
      if word[0] == "-"
        str << " NOT"
        word.slice!(0)
      end
      word = escape_reserved_characters(word)
      str << " #{fieldname}:#{word}"
    end
    str
  end

  def make_bool(query)
    query.reject! { |_, value| value.blank? }
    query[:minimum_should_match] = 1 if query[:should].present?

    if query.values.flatten.size == 1 && (query[:must] || query[:should])
      # There's only one clause in our boolean, so we might as well skip the
      # bool and just require it.
      query.values.flatten.first
    else
      { bool: query }
    end
  end
end
