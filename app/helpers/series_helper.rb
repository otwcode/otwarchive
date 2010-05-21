module SeriesHelper 
  
  def show_series_data(work)
    # this should only show prev and next works visible to the current user
    series = work.series.select{|s| s.visible?(current_user)}
    series_data = series.map do |serial|
      # cull visible works
      serial_works = serial.serial_works.find(:all, :include => :work, :conditions => ['works.posted = ?', true], :order => :position).select{|sw| sw.work.visible(current_user)}.collect{|sw| sw.work}
      visible_position = serial_works.index(work) || serial_works.length     
      unless !visible_position
        previous_link = (visible_position > 0) ? link_to("&laquo; ", serial_works[visible_position - 1]) : ""
        main_link = "Part " + (visible_position+1).to_s + " of the " + link_to(serial.title, serial) + " series"
        next_link = (visible_position < serial_works.size-1) ? link_to(" &raquo;", serial_works[visible_position + 1]) : ""
        previous_link + main_link + next_link
      end
    end
    series_data.join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
  end
  
  def get_series_title_string(tags, category_name = "")
    if tags && tags.size > 0
      tags.collect(&:name).join(", ")
    else
      category_name.blank? ? "" : "No" + " " + category_name
    end
  end
  
  def get_series_symbols_for(series, symbols_only = false)
    mappings = {}
    warnings = series.work_tags.select{|tag| tag.type == "Warning"}
    mappings[:warning] = {:class_name => get_series_warnings_class(warnings), :string =>  get_series_title_string(warnings)}
    
    ratings = series.work_tags.select{|tag| tag.type == "Rating"}
    mappings[:rating] = {:class_name => get_series_ratings_class(ratings), :string =>  get_title_string(ratings, "rating")}
    
    categories = series.work_tags.select{|tag| tag.type == "Category"}
    mappings[:category] = {:class_name => get_series_category_class(categories), :string =>  get_series_title_string(categories, "category")}
    
    # placeholder
    iswip_string = true ? "Series in Progress" : "Complete Series"
    mappings[:iswip] = {:class_name => get_series_complete_class(series), :string =>  iswip_string}

    symbol_block = ""
        symbol_block << "<ul class=\"required-tags\">\n" if not symbols_only
        %w(rating category warning iswip).each do |w|
          css_class = mappings[w.to_sym][:class_name]
          title_string = mappings[w.to_sym][:string]
          symbol_block << "<li>"
          symbol_block << link_to_help('symbols-key', link = "<div class=\"#{css_class}\" title=\"#{title_string}\"><span>" + title_string + "</span></div>")
          symbol_block << "</li>\n"
        end
        symbol_block << "</ul>\n" if not symbols_only
        return symbol_block
      end

  def get_series_warnings_class(warning_tags)
    return "warning-yes warnings" unless warning_tags
    none = true
    choosenotto = true
    warning_tags.map(&:name).each do |name|
      none = false if name != ArchiveConfig.WARNING_NONE_TAG_NAME
      choosenotto = false if name !=ArchiveConfig.WARNING_DEFAULT_TAG_NAME && name != ArchiveConfig.WARNING_NONE_TAG_NAME
    end
    return "warning-no warnings" if none
    return "warning-choosenotto warnings" if choosenotto
    "warning-yes warnings"
  end

  def get_series_ratings_class(rating_tags)
    if rating_tags.blank?
      "rating-notrated rating"
    else
      names = rating_tags.collect(&:name)
      if names.include?(ArchiveConfig.RATING_EXPLICIT_TAG_NAME)
        "rating-explicit rating"
      elsif names.include?(ArchiveConfig.RATING_MATURE_TAG_NAME)
        "rating-mature rating"
      elsif names.include?(ArchiveConfig.RATING_TEEN_TAG_NAME)
        "rating-teen rating"
      elsif names.include?(ArchiveConfig.RATING_GENERAL_TAG_NAME)
        "rating-general-audience rating"
      else
        "rating-notrated rating"
      end
    end
  end

  def get_series_category_class(category_tags)
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

  #TODO: add complete attribute to series and adjust accordingly
  def get_series_complete_class(series)
    "category-none iswip"
  end
  
  # TODO: merge with work_blurb_tag_block
  def series_blurb_tag_block(series)    
    warnings = series.work_tags.select{|tag| tag.type == "Warning"}.sort
    pairings = series.work_tags.select{|tag| tag.type == "Pairing"}.sort
    characters = series.work_tags.select{|tag| tag.type == "Character"}.sort
    freeforms = series.work_tags.select{|tag| tag.type == "Freeform"}.sort

    last_tag = (warnings + pairings + characters + freeforms).last
    tag_block = ""

    [warnings, pairings, characters, freeforms].each do |tags|
      unless tags.empty?
        class_name = tags.first.type.to_s.downcase.pluralize
        if (class_name == "warnings" && hide_warnings?(series)) || (class_name == "freeforms" && hide_freeform?(series))
          open_tags = "<li class='#{class_name}' id='series_#{series.id}_category_#{class_name}'><strong>"
          close_tags = "</strong></li>"
          delimiter = (class_name == 'freeforms' || last_tag.is_a?(Warning)) ? '' : ArchiveConfig.DELIMITER_FOR_OUTPUT
          tag_block <<  open_tags + show_hidden_tags_link(series, class_name) + delimiter + close_tags
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
  
end
