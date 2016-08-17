class WorkSearchForm

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [
    :query, 
    :title, 
    :creator, 
    :revised_at, 
    :language_id, 
    :complete, 
    :single_chapter,
    :word_count, 
    :hits, 
    :kudos_count, 
    :bookmarks_count, 
    :comments_count, 
    :pseud_ids,
    :collection_ids,
    :tag,
    :excluded_tag_names,
    :other_tag_names,
    :filter_ids,
    :fandom_names,
    :fandom_ids,
    :rating_ids,
    :category_ids,
    :warning_ids,
    :character_names,
    :character_ids,
    :relationship_names,
    :relationship_ids,
    :freeform_names,
    :freeform_ids,
    :sort_column,
    :sort_direction,
    :page
  ]

  attr_accessor :options
    
  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(options={})
    @options = options
    @searcher = WorkQuery.new(options.delete_if { |k, v| v.blank? })
  end

  def persisted?
    false
  end

  def summary
  end

  def search_results
    @searcher.search_results
  end

  ###############
  # SORTING
  ###############

  SORT_OPTIONS = [
    ['Author', 'authors_to_sort_on'],
    ['Title', 'title_to_sort_on'],
    ['Date Posted', 'created_at'],
    ['Date Updated', 'revised_at'],
    ['Word Count', 'word_count'],
    ['Hits', 'hits'],
    ['Kudos', 'kudos_count'],
    ['Comments', 'comments_count'],
    ['Bookmarks', 'bookmarks_count']
  ]

  def sort_column
    @sort_column || 'revised_at'
  end

  def sort_direction
    @sort_direction || default_sort_direction
  end
  
  def sort_options
    SORT_OPTIONS
  end
  
  def sort_values
    sort_options.map{ |option| option.last }
  end
  
  # extract the pretty name
  def name_for_sort_column(sort_column)
    Hash[SORT_OPTIONS.collect {|v| [ v[1], v[0] ]}][sort_column]
  end
  
  def default_sort_direction
    if %w(authors_to_sort_on title_to_sort_on).include?(sort_column)
      'asc'
    else
      'desc'
    end
  end

end