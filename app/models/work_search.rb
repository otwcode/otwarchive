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
    :sort_column
    
  def options_for_search
    if options[:title].present?
      options[:title_to_sort_on] = options[:title]
    end
    if options[:rating_ids].present?
      options[:rating_ids] = [options[:rating_ids]].flatten
    end
    [:fandom_names, :character_names, :relationship_names, :freeform_names].each do |tag_names|
      if options[tag_names].present?
        names = options[tag_names].split(",")
        tag_ids = tag_names.to_s.gsub("names", "ids").to_sym
        options[tag_ids] = Tag.where(:name => names).value_of(:id)
      end
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
    options.delete(:complete) if options[:complete] == "0"
    options.each_pair do |key, value|
      options.delete(key) if value.blank?
    end
    options
  end
  
end