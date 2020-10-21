class CollectionSearchForm

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [
    :title,
    :challenge_type,
    :signup_open,
    :unrevealed,
    :anonymous,
    :closed,
    :moderated,
    :fandom_ids,
    :owner_ids,
    :parent_id,
    :moderator_ids,
    :signups_open_at,
    :signups_close_at,
    :assignments_due_at,
    :works_reveal_at,
    :authors_reveal_at,
    :sort_column,
    :sort_direction,
    :page
  ]

  attr_accessor :options

  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(opts={})
    @options = opts
    process_options
    @searcher = CollectionQuery.new(@options)
  end

  def process_options
    @options.delete_if { |k, v| v == "0" || v.blank? }
    set_sorting
  end

  def set_sorting
    @options[:sort_column] ||= default_sort_column
    @options[:sort_direction] ||= default_sort_direction
  end

  def persisted?
    false
  end

  def summary
    summary = []
    if @options[:title].present?
      summary << "Title: #{@options[:title]}"
    end

    if @options[:sort_column].present?
      summary << "sort by: #{name_for_sort_column(@options[:sort_column]).downcase}" +
        (@options[:sort_direction].present? ?
          (@options[:sort_direction] == "asc" ? " ascending" : " descending") : "")
    end
    summary.join(" ")
  end

  def search_results
    @searcher.search_results
  end

  ###############
  # SORTING
  ###############

  SORT_OPTIONS = [
    ['Date Posted', 'created_at'],
    ['Title', 'title']
  ].freeze

  def sort_columns
    options[:sort_column] || default_sort_column
  end

  def sort_direction
    options[:sort_direction] || default_sort_direction
  end

  def sort_options
    options[:faceted] || options[:collected] ? SORT_OPTIONS[1..-1] : SORT_OPTIONS
  end

  def sort_values
    sort_options.map{ |option| option.last }
  end

  # extract the pretty name
  def name_for_sort_column(sort_column)
    Hash[SORT_OPTIONS.map { |v| [v[1], v[0]] }][sort_column]
  end

  def default_sort_column
    'created_at'
  end

  def default_sort_direction
    if sort_column.include?('title') || sort_column.include?('signups_close_at')
      'asc'
    else
      'desc'
    end
  end
end
