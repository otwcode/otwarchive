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
    :owner_ids,
    :parent_id,
    :moderator_ids,
    :maintainer_id,
    :signups_open_at,
    :signups_close_at,
    :assignments_due_at,
    :works_reveal_at,
    :authors_reveal_at,
    :sort_column,
    :sort_direction,
    :tag,
    :filter_ids,
    :fandom_names,
    :fandom_ids,
    :rating_ids,
    :category_ids,
    :archive_warning_ids,
    :character_names,
    :character_ids,
    :relationship_names,
    :relationship_ids,
    :freeform_names,
    :freeform_ids,
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

  def search_results
    @searcher.search_results
  end

  ###############
  # SORTING
  ###############

  SORT_OPTIONS = [
    ["Date Created", "created_at"],
    ["Title", "title.keyword"]
  ].freeze

  def sort_columns
    options[:sort_column] || default_sort_column
  end

  def sort_direction
    options[:sort_direction] || default_sort_direction
  end

  def sort_options
    SORT_OPTIONS
  end

  def sort_values
    sort_options.map{ |option| option.last }
  end

  # extract the pretty name
  def name_for_sort_column(sort_column)
    Hash[SORT_OPTIONS.map { |v| [v[1], v[0]] }][sort_column]
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
