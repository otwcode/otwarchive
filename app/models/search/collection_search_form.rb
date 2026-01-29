class CollectionSearchForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = %i[
    challenge_type
    closed
    maintainer_id
    moderated
    multifandom
    page
    parent_id
    per_page
    signup_open
    sort_column
    sort_direction
    tag
    title
  ].freeze

  attr_accessor :options

  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(opts = {}, admin_logged_in = false) # rubocop:disable Style/OptionalBooleanParameter
    @options = opts
    @options[:admin_logged_in] = admin_logged_in
    process_options
    @searcher = CollectionQuery.new(@options)
  end

  def process_options
    @options.delete_if { |_k, v| v == "0" || v.blank? }
    set_sorting
  end

  def set_sorting
    @options[:sort_column] ||= default_sort_column
    @options[:sort_direction] ||= default_sort_direction
  end

  def persisted?
    false
  end

  def search_results
    @searcher.search_results
  end

  ###############
  # SORTING
  ###############

  def sort_column
    options[:sort_column] || default_sort_column
  end

  def sort_direction
    options[:sort_direction] || default_sort_direction
  end

  def sort_options
    [
      ["Date Created", "created_at"],
      %w[Title title.keyword],
      ["Bookmarked Items", "public_bookmarked_items_count"],
      %w[Works public_works_count]
    ].freeze
  end

  def default_sort_column
    "created_at"
  end

  def default_sort_direction
    if sort_column.include?("title") || sort_column.include?("signups_close_at")
      "asc"
    else
      "desc"
    end
  end
end
