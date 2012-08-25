class WorkSearch < Search
  
  serialized_options :query, 
    :title, 
    :byline, 
    :revised_at, 
    :language_id, 
    :complete, 
    :word_count, 
    :hits, 
    :kudos_count, 
    :bookmarks_count, 
    :comments_count, 
    :pseud_ids,
    :collection_ids,
    :tag_names,
    :fandom_ids,
    :rating_ids,
    :category_ids,
    :warning_ids,
    :character_ids,
    :relationship_ids,
    :freeform_ids,
    :sort_column
    
  def options_for_search
    if options[:title].present?
      options[:title_to_sort_on] = options[:title]
    end
    case options[:sort_column]
    when 'author'
      options[:sort_column] = 'authors_to_sort_on'
    when 'title'
      options[:sort_column] = 'title_to_sort_on'
    when 'date'
      options[:sort_column] = 'revised_at'
    end
    unless Work.sort_values.include?(options[:sort_column])
      options[:sort_column] = 'revised_at'
    end
    options[:sort_direction] = Work.sort_direction(options[:sort_column])
    options
  end
  
end