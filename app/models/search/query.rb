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
    QueryResult.new(klass, response, options.slice(:page, :per_page))
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
      query: { bool: filtered_query },
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
  # Don't include empty conditions, since those will affect results
  def filtered_query
    filtered_query = {}
    filtered_query[:filter] = filter_bool if filter_bool.present?
    filtered_query[:must] = query_bool if query_bool.present?
    if should_query.present?
      filtered_query[:should] = should_query
      filtered_query[:minimum_should_match] = 1
    end
    filtered_query
  end

  # Boolean filter
  def filter_bool
    return unless filters.present?
    bool = { bool: { must: filters } }
    if exclusion_filters.present?
      bool[:bool][:must_not] = exclusion_filters
    end
    bool
  end

  # Boolean query
  def query_bool
    queries if !queries.blank?
  end

  # Should queries (used primarily for bookmarks)
  def should_query
    @should_queries
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
    options[:per_page] || 20
  end

  def pagination_offset
    page = options[:page] || 1
    (page * per_page) - per_page
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
end
