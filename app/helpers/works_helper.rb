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
    @work.new_record? ? Tag.default_warning.collect : @work.tags.by_category(category).valid.collect(&:name)
  end
  
  def get_symbols_for(work)
    @tags_by_category = Tag.on_works([work]).group_by(&:tag_category_id).to_hash

    warning_class = get_warnings_class(@tags_by_category[WARNING_TAG_CATEGORY.id])
    warning_string = @tags_by_category[WARNING_TAG_CATEGORY.id].collect(&:name).join(", ")
    
    rating = @tags_by_category[RATING_TAG_CATEGORY.id].blank? ? nil : @tags_by_category[RATING_TAG_CATEGORY.id].first
    rating_class = get_ratings_class(rating)
    rating_string = rating.nil? ? "No Rating".t : rating.name    

    category = @tags_by_category[CATEGORY_TAG_CATEGORY.id].blank? ? nil : @tags_by_category[CATEGORY_TAG_CATEGORY.id].first
    category_class = get_category_class(category)
    category_string = category.nil? ? "No Category".t : category.name
    
    iswip_class = get_complete_class(work)
    iswip_string = work.is_wip ? "Work in Progress".t : "Complete Work".t

    symbol_block = "<ul class=\"required-tags\">\n"
    %w(rating category warning iswip).each do |w|
      css_class = eval("#{w}_class")
      title_string = eval("#{w}_string")
      symbol_block << "<li class=#{css_class}><span><span title=\"#{title_string}\">"
      symbol_block << image_tag( "#{css_class}.png", :alt => title_string, :title => title_string)
      symbol_block << "</span></span></li>\n"
    end
    symbol_block << "</ul>\n"
  end
  
  def get_warnings_class(warning_tags)
    # check for warnings
    if warning_tags && warning_tags.include?(NO_WARNING_TAG)
      "warning-no"
    else
      "warning-yes"
    end
  end
    
  def get_ratings_class(rating_tag)
    case rating_tag
    when EXPLICIT_RATING_TAG
      "rating-explicit"
    when MATURE_RATING_TAG
      "rating-mature"
    when TEEN_RATING_TAG
      "rating-teen"
    when GENERAL_RATING_TAG
      "rating-general-audience"
    else
      "rating-notrated"
    end
  end


  def get_category_class(category_tag)
    case category_tag
    when GEN_CATEGORY_TAG
      "category-gen"
    when SLASH_CATEGORY_TAG
      "category-slash"
    when HET_CATEGORY_TAG
      "category-het"
    when FEMSLASH_CATEGORY_TAG
      "category-femslash"
    when MULTI_CATEGORY_TAG
      "category-multi"
    when OTHER_CATEGORY_TAG
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












  
end
