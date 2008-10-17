module WorksHelper 
  
  # For use with chapter virtual attributes
  def fields_for_associated(creation, associated, &block)
    fields_for(name_attributes(creation, associated.class.to_s.downcase), associated, &block)
  end
  
  def name_attributes(creation, attribute_type)
   creation + "[" + attribute_type + "_attributes]" 
  end
  
  # Returns message re: number of posted chapters/number of expected chapters 
  def wip_message(work)
    posted = work.number_of_posted_chapters
    posted = 1 if posted == 0
    "Please note this is a work in progress, with ".t + posted.to_s + " of ".t + work.wip_length.to_s + " chapters posted.".t  
  end
  
#  def view_all_chapters_link(work)
#    #link_to_remote "View entire work".t, {:url => {:controller => :chapters, :action => :index, :work_id => work, :old_chapter => chapter.id}, :method => :get},
#    #                                      {:href => work_path(work)} 
#    link_to "View entire work".t, work_path(work) 
#  end
  
  def view_chapter_link(work, chapter)
    #link_to_remote "View by chapters".t, {:url => {:controller => :chapters, :action => :show, :work_id => work, :id => work.first_chapter}, :method => :get},
    #                                        {:href => url_for({:controller => :chapters, :action => :show, :work_id => work, :id => work.first_chapter})} 
    link_to "View by chapters".t, url_for({:controller => :chapters, :action => :show, :work_id => work, :id => chapter})
  end
  
  # Determines whether or not to display warnings for a work 
  def hide_warnings?(work)
    current_user.is_a?(User) && current_user.preference && current_user.preference.hide_warnings? && !current_user.is_author_of?(work)
  end
  
  # Link to show warnings if they're currently hidden
  def show_warnings_link(work, category)
    link_to_remote "Show warnings".t, 
      :url => {:controller => 'tags', :action => 'show_hidden', :work_id => work.id, :category_id => category.id}, 
      :method => :get
  end
    
  # modified from mislav-will_paginate-2.3.2/lib/will_paginate/view_helpers.rb
  def search_header(collection, search_query)
    if search_query.blank?
      search_query = " found"
    else
      search_query = html_escape search_query
      search_query = " found for '".t + search_query + "'"
    end
    if collection.total_pages < 2
      case collection.size
      when 0; "0 Works".t + search_query
      when 1; "1 Work".t + search_query
      else; collection.total_entries.to_s + " Works".t + search_query
      end
    else
      %{ %d - %d of %d }% [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ] + "Works".t + search_query
    end
  end

  # select the default warnings if this is a new work
  def warning_selected(work, category)
    @work.new_record? ? Tag.default_warning : @work.tags.by_category(category).valid.collect(&:name)
  end
  
  def get_tags_by_category(work)
    if !@tags_by_category_work || @tags_by_category_work != work
      @tags_by_category_work = work
      @tags_by_category = nil
    end
    @tags_by_category ||= Tag.on_works([work]).group_by(&:tag_category_id).to_hash
  end
  
  def get_title_string(tags, category_name = "")
    if tags && tags.size > 0
      tags.collect(&:name).join(", ")
    else
      category_name.blank? ? "" : "No".t + " " + category_name
    end
  end
  
  def get_symbols_for(work)
    tags_by_category = get_tags_by_category(work)

    warning_class = get_warnings_class(tags_by_category[TagCategory::WARNING.id])
    warning_string = get_title_string(tags_by_category[TagCategory::WARNING.id])
    
    rating = tags_by_category[TagCategory::RATING.id].blank? ? nil : tags_by_category[TagCategory::RATING.id].first
    rating_class = get_ratings_class(rating)
    rating_string = get_title_string(tags_by_category[TagCategory::RATING.id], "rating".t)

    category = tags_by_category[TagCategory::CATEGORY.id].blank? ? nil : tags_by_category[TagCategory::CATEGORY.id].first
    category_class = get_category_class(category)
    category_string = get_title_string(tags_by_category[TagCategory::CATEGORY.id], "category".t)
    
    iswip_class = get_complete_class(work)
    iswip_string = work.is_wip ? "Work in Progress".t : "Complete Work".t

    symbol_block = "<ul class=\"required-tags\">\n"
    %w(rating category warning iswip).each do |w|
      css_class = eval("#{w}_class")
      title_string = eval("#{w}_string")
      symbol_block << "<li class=#{css_class}>"
      symbol_block << link_to_help('symbols-key', link = image_tag( "#{css_class}.png", :alt => title_string, :title => title_string))
      symbol_block << "</li>\n"
    end
    symbol_block << "</ul>\n"
  end
  
  def get_warnings_class(warning_tags)
    # check for warnings
    if warning_tags && warning_tags.include?(Tag::NO_WARNING_TAG)
      "warning-no"
    else
      "warning-yes"
    end
  end
    
  def get_ratings_class(rating_tag)
    case rating_tag
    when Tag::EXPLICIT_RATING_TAG
      "rating-explicit"
    when Tag::MATURE_RATING_TAG
      "rating-mature"
    when Tag::TEEN_RATING_TAG
      "rating-teen"
    when Tag::GENERAL_RATING_TAG
      "rating-general-audience"
    else
      "rating-notrated"
    end
  end

  def get_category_class(category_tag)
    case category_tag
    when Tag::GEN_CATEGORY_TAG
      "category-gen"
    when Tag::SLASH_CATEGORY_TAG
      "category-slash"
    when Tag::HET_CATEGORY_TAG
      "category-het"
    when Tag::FEMSLASH_CATEGORY_TAG
      "category-femslash"
    when Tag::MULTI_CATEGORY_TAG
      "category-multi"
    when Tag::OTHER_CATEGORY_TAG
      "category-other"
    else
      "category-none"
    end
  end

  def get_complete_class(work)
    if work.is_wip
      "complete-no"
    else
      "complete-yes"
    end
  end

  def cast_tags_for(work)
    tags_by_category = get_tags_by_category(work)
    
    # we combine pairing and character tags up to the limit
    characters = tags_by_category[TagCategory::CHARACTER.id] || []
    pairings = tags_by_category[TagCategory::PAIRING.id] || []
    return [] if pairings.empty? && characters.empty? 
    
    relationship = TagRelationshipKind.find_by_name('child')
    if relationship 
      pairings.each do |pairing|
        characters.reject!{|c| c.is_in_relationship_with?(pairing, relationship)}
      end
    end
    
    cast = pairings + characters
    if cast.size > ArchiveConfig.TAGS_PER_LINE
      cast = cast[0..(ArchiveConfig.TAGS_PER_LINE-1)]
    end

    return cast
  end
  
  def freeform_tags_for(work)
    tags_by_category = get_tags_by_category(work)
    
    warnings = tags_by_category[TagCategory::WARNING.id] || []
    freeform = tags_by_category[TagCategory::DEFAULT.id] || []

    tags = warnings + freeform
    if tags.size > ArchiveConfig.TAGS_PER_LINE
      tags = tags[0..(ArchiveConfig.TAGS_PER_LINE-1)]
    end
    return tags
  end
  
  # Use time_ago_in_words if less than a month ago, otherwise display date
  def set_format_for_date(date)
    return "" unless date.is_a? Date
    if date > 30.days.ago
      time_ago_in_words(date)
    else
      date.to_date.to_formatted_s(:rfc822)
    end
  end

end
