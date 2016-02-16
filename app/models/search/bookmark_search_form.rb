class BookmarkSearchForm

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [
    :query, 
    :rec,
    :notes,
    :with_notes,
    :date,
    :show_private,
    :pseud_ids,
    :bookmarker, 
    :bookmarkable_pseud_names, 
    :bookmarkable_pseud_ids, 
    :bookmarkable_type,    
    :tag, 
    :other_tag_names,
    :tag_ids, 
    :filter_ids,
    :filter_names, 
    :fandom_ids, 
    :character_ids, 
    :relationship_ids, 
    :freeform_ids, 
    :rating_ids, 
    :warning_ids, 
    :category_ids, 
    :bookmarkable_title, 
    :bookmarkable_date,
    :bookmarkable_complete, 
    :bookmarkable_language_id, 
    :collection_ids, 
    :bookmarkable_collection_ids,
    :sort_column,
    :show_restricted,
    :page
  ]

  attr_accessor :options
    
  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(options={})
    @options = options
    @searcher = BookmarkQuery.new(options.delete_if { |k, v| v.blank? })
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

  def sort_options
    [
      ['Date Bookmarked', 'created_at'],
      ['Date Updated', 'bookmarkable_date'],
    ]
  end
  
  def sort_values
    sort_options.map{ |option| option.last }
  end
  
  def sort_direction(sort_column)
    'desc'
  end

end