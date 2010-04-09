module WorksHelper

  # For use with chapter virtual attributes
  def fields_for_associated(creation, associated, &block)
    fields_for(name_attributes(creation, associated.class.to_s.downcase), associated, &block)
  end

  def name_attributes(creation, attribute_type)
   creation + "[" + attribute_type + "_attributes]"
  end
  
  # List of date, chapter and length info for the work show page
  def work_meta_list(work, chapter=nil)
    # if we're previewing, grab the unsaved date, else take the saved first chapter date
    published_date = (chapter && work.preview_mode) ? chapter.published_at : work.first_chapter.published_at
    list = [[t('works_helper.published', :default => "Published:"), localize(published_date)], [t('works_helper.words', :default => "Words:"), work.word_count], 
            [t('works_helper.chapters', :default => "Chapters:"), work.chapter_total_display]]

    if work.count_visible_comments > 0
      list.concat([[t('work_comments', :default => 'Comments') + ':', work.count_visible_comments.to_s]])
    end
    if (bookmark_count = Bookmark.count_visible_bookmarks(work)) > 0
      list.concat([[t('work_bookmarks', :default => 'Bookmarks') + ':', link_to(bookmark_count.to_s, work_bookmarks_path(work))]])
    end
    list.concat([[t('works_helper.hits:', :default => "Hits:"), work.hit_count]]) if show_hit_count?(work)

    if work.chaptered? && work.revised_at
      prefix = work.is_wip ? "Updated:" : "Completed:"
      latest_date = (work.preview_mode && work.backdate) ? published_date : work.revised_at.to_date
      list.insert(1, [prefix, localize(latest_date)])
    end
    
    '<dl>' + list.map {|l| '<dt>' + l.first + '</dt><dd>' + l.last.to_s + '</dd>'}.to_s + '</dl>'
  end

  def show_hit_count?(work)
    return false if logged_in? && current_user.preference.hide_all_hit_counts
    author_wants_to_see_hits = is_author_of?(work) && !current_user.preference.hide_private_hit_count
    all_authors_want_public_hits = work.users.select {|u| u.preference.hide_public_hit_count}.empty?
    author_wants_to_see_hits || (!is_author_of?(work) && all_authors_want_public_hits)
  end

  def work_top_links_list(work)
    collections_link = work.approved_collections.empty? ? '' : 
      ("<li>" + link_to(t('work_collections_link', :default => "Collections: {{num_of_collections}}", 
                          :num_of_collections => work.approved_collections.length), work_collections_path(work)) + "</li>")
    bookmark_link = logged_in? ? '<li>' + bookmark_link(work) + '</li>' : ''			
    comments_link = '<li>' + link_to("Comment(s)", work_path(work, :show_comments => true, :anchor => 'comments')) + '</li>'  
    "<ul>" + bookmark_link + (comments_link ||= '') + collections_link + "</ul>"    
  end

  def work_blurb_tag_block(work)
    tags = work.warning_tags + work.pairing_tags + work.character_tags + work.freeform_tags
    last_tag = tags.last
    tag_block = ""

    [work.warning_tags, work.pairing_tags, work.character_tags, work.freeform_tags].each do |tags|
      unless tags.empty?
        class_name = tags.first.type.downcase.pluralize
        if (class_name == "warnings" && hide_warnings?(work)) || (class_name == "freeforms" && hide_freeform?(work))
          open_tags = "<li class='#{class_name}' id='work_#{work.id}_category_#{class_name}'><strong>"
          close_tags = "</strong></li>"
          delimiter = (class_name == 'freeforms' || last_tag.is_a?(Warning)) ? '' : ArchiveConfig.DELIMITER_FOR_OUTPUT
          tag_block <<  open_tags + show_hidden_tags_link(work, class_name) + delimiter + close_tags
        elsif class_name == "warnings"
          open_tags = "<li class='#{class_name}'><strong>"
          close_tags = "</strong></li>"
          link_array = tags.collect{|tag| link_to_tag(tag) + (tag == last_tag ? '' : ArchiveConfig.DELIMITER_FOR_OUTPUT) }
          tag_block <<  open_tags + link_array.join("</strong></li> <li class='#{class_name}'><strong>") + close_tags
        else
          link_array = tags.collect{|tag| link_to_tag(tag) + (tag == last_tag ? '' : ArchiveConfig.DELIMITER_FOR_OUTPUT) }
          tag_block << "<li class='#{class_name}'>" + link_array.join("</li> <li class='#{class_name}'>") + '</li>'        
        end
      end
    end
    tag_block
  end

  def work_collection_names_list(work)
    work.approved_collections.map {|collection| link_to(h(collection.title), collection)}.to_sentence
  end
  
  # work.tags doesn't include unsaved tags on preview
  def collect_work_tags(work)
    if work.preview_mode
      work.placeholder_tags.values.flatten
    else
      work.tags
    end  
  end

  
  # modified from mislav-will_paginate-2.3.2/lib/will_paginate/view_helpers.rb
  def search_header(collection, search_query)
    if search_query.blank?
      search_query = " found"
    else
      search_query = html_escape search_query
      search_query = " found for '" + search_query + "'"
    end
    if collection.total_pages < 2
      case collection.size
      when 0; "0 Works" + search_query
      when 1; "1 Work" + search_query
      else; collection.total_entries.to_s + " Works" + search_query
      end
    else
      %{ %d - %d of %d }% [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ] + "Works" + search_query
    end
  end
  
  def recipients_link(work)
    work.gifts.map {|gift| link_to(h(gift.recipient), gift.pseud ? user_gifts_path(gift.pseud.user) : gifts_path(:recipient => gift.recipient_name))}.join(", ")
  end
  
  # Making absolutely sure that the tags and selected tags have the same capitalization so it doesn't throw the form off
  def warnings_for_tag_form
    [ArchiveConfig.WARNING_DEFAULT_TAG_NAME, ArchiveConfig.WARNING_NONE_TAG_NAME, ArchiveConfig.WARNING_VIOLENCE_TAG_NAME, ArchiveConfig.WARNING_DEATH_TAG_NAME, ArchiveConfig.WARNING_NONCON_TAG_NAME, ArchiveConfig.WARNING_CHAN_TAG_NAME]
  end

  # select the default warning if this is a new work
  def check_warning(work, warning)
    if work.nil? || work.warning_strings.empty? 
      warning.name == ArchiveConfig.WARNING_DEFAULT_TAG_NAME 
    else
      work.warning_strings.include?(warning.name)
    end
  end
  
  # select default rating if this is a new work
  def rating_selected(work)
    work.nil? || work.rating_string.empty? ? ArchiveConfig.RATING_DEFAULT_TAG_NAME : work.rating_string
  end
  
  def category_selected(work)
    work.nil? || work.category_string.empty? ? ArchiveConfig.CATEGORY_DEFAULT_TAG_NAME : work.category_string
  end

  def get_title_string(tags, category_name = "")
    if tags && tags.size > 0
      tags.collect(&:name).join(", ")
    else
      category_name.blank? ? "" : "No" + " " + category_name
    end
  end
  
  def get_symbols_for(work, symbols_only = false)
    mappings = {}
    unless work.class == ExternalWork
      warnings = work.tags.select{|tag| tag.type == "Warning"}
      mappings[:warning] = {:class_name => get_warnings_class(warnings), :string =>  get_title_string(warnings)}
    else
      mappings[:warning] = {:class_name => 'external-work', :string =>  "External Work"}
    end
    
    ratings = work.tags.select{|tag| tag.type == "Rating"}
    rating = ratings.blank? ? nil : ratings.first
    mappings[:rating] = {:class_name => get_ratings_class(rating), :string =>  get_title_string(ratings, "rating")}
    
    categories = work.tags.select{|tag| tag.type == "Category"}
    mappings[:category] = {:class_name => get_category_class(categories), :string =>  get_title_string(categories, "category")}
    
    if work.class == Work
      iswip_string = work.is_wip ? "Work in Progress" : "Complete Work"
    else
      iswip_string = "External Work"
    end
    mappings[:iswip] = {:class_name => get_complete_class(work), :string =>  iswip_string}

    symbol_block = ""
    symbol_block << "<ul class=\"required-tags\">\n" if not symbols_only
    %w(rating category warning iswip).each do |w|
      css_class = mappings[w.to_sym][:class_name]
      title_string = mappings[w.to_sym][:string]
      symbol_block << "<li><div class=\"#{css_class}\" title=\"#{title_string}\"><span>"
      symbol_block << link_to_help('symbols-key', link = title_string)
      symbol_block << "</span></div></li>\n"
    end
    symbol_block << "</ul>\n" if not symbols_only
    return symbol_block
  end

  def get_warnings_class(warning_tags)
    return "warning-yes warnings" unless warning_tags
    none = true
    choosenotto = true
    warning_tags.map(&:name).each do |name|
      none = false if name != ArchiveConfig.WARNING_NONE_TAG_NAME
      choosenotto = false if name !=ArchiveConfig.WARNING_DEFAULT_TAG_NAME
    end
    return "warning-no warnings" if none
    return "warning-choosenotto warnings" if choosenotto
    "warning-yes warnings"
  end

  def get_ratings_class(rating_tag)
    return "rating-notrated rating" unless rating_tag
    case rating_tag.name
    when ArchiveConfig.RATING_EXPLICIT_TAG_NAME
      "rating-explicit rating"
    when ArchiveConfig.RATING_MATURE_TAG_NAME
      "rating-mature rating"
    when ArchiveConfig.RATING_TEEN_TAG_NAME
      "rating-teen rating"
    when ArchiveConfig.RATING_GENERAL_TAG_NAME
      "rating-general-audience rating"
    else
      "rating-notrated rating"
    end
  end

  def get_category_class(category_tags)
    if category_tags.blank?
      "category-none category"
    elsif category_tags.length > 1
      "category-multi category"
    else
      case category_tags.first.name
      when ArchiveConfig.CATEGORY_GEN_TAG_NAME
        "category-gen category"
      when ArchiveConfig.CATEGORY_SLASH_TAG_NAME
        "category-slash category"
      when ArchiveConfig.CATEGORY_HET_TAG_NAME
        "category-het category"
      when ArchiveConfig.CATEGORY_FEMSLASH_TAG_NAME
        "category-femslash category"
      when ArchiveConfig.CATEGORY_MULTI_TAG_NAME
        "category-multi category"
      when ArchiveConfig.CATEGORY_OTHER_TAG_NAME
        "category-other category"
      else
        "category-none category"
      end
    end
  end

  def get_complete_class(work)
    return "category-none" if work.class == ExternalWork
    if work.is_wip
      "complete-no iswip"
    else
      "complete-yes iswip"
    end
  end
  
  # Determines whether or not to expand the related work association fields when the work form loads
  def check_parent_box(work)
    !work.parent_work_relationships.blank? || 
    (params[:work] && !(work_parent_value(:url).blank? && work_parent_value(:title).blank? && work_parent_value(:author).blank?))
  end
  
  # Passes value of fields for related works back to form when an error occurs on posting
  def work_parent_value(field)
    if params[:work] && params[:work][:parent_attributes]
      params[:work][:parent_attributes][field]
    end
  end
  
  # Return true or false to determine whether the published at field should show on the work form
  def check_backdate_box(work, chapter)
    work.backdate || (chapter.created_at && chapter.created_at.to_date != chapter.published_at)
  end

  # Use time_ago_in_words if less than a month ago, otherwise display date
  def set_format_for_date(datetime)
    return "" unless datetime.is_a? Time
    if datetime > 30.days.ago && !AdminSetting.enable_test_caching?
      time_ago_in_words(datetime)
    else
      datetime.to_date.to_formatted_s(:rfc822)
    end
  end

  # which controllers are allowed to display anonymous works on user pages
  def allowed_controllers
    ['gifts', 'readings'].include?(controller.controller_name)
  end
end
