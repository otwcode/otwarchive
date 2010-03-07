module SeriesHelper 
  
  def show_series_data(work)
    # this should only show prev and next works visible to the current user
    series = work.series.select{|s| s.visible?(current_user)}
    series.map do |serial|
      # cull visible works
      serial_works = serial.serial_works.find(:all, :include => :work, :conditions => ['works.posted = ?', true], :order => :position).select{|sw| sw.work.visible(current_user)}.collect{|sw| sw.work}
      visible_position = serial_works.index(work) if serial_works     
      unless !visible_position # is nil if work is a draft 
        previous_link = (visible_position > 0) ? link_to("&#8592; ", serial_works[visible_position - 1]) : ""
        main_link = "Part " + (visible_position+1).to_s + " of the " + link_to(serial.title, serial) + " series"
        next_link = (visible_position < serial_works.size-1) ? link_to(" &#8594;", serial_works[visible_position + 1]) : ""
        previous_link + main_link + next_link
      end
    end
  end
  
  def get_series_title_string(tags, category_name = "")
    if tags && tags.size > 0
      tags.collect(&:name).join(", ")
    else
      category_name.blank? ? "" : "No" + " " + category_name
    end
  end
  
  def get_series_symbols_for(series, symbols_only = false)
    warnings = series.tags.select{|tag| tag.type == "Warning"}
    warning_class = get_series_warnings_class(warnings)
    warning_string = get_series_title_string(warnings)
    
    ratings = series.tags.select{|tag| tag.type == "Rating"}
    rating_class = get_series_ratings_class(ratings)
    rating_string = get_series_title_string(ratings, "rating")
    
    categories = series.tags.select{|tag| tag.type == "Category"}
    category_class = get_series_category_class(categories)
    category_string = get_series_title_string(categories, "category")

    iswip_class = get_series_complete_class(series)
    iswip_string = true ? "Series in Progress" : "Complete Series"

    symbol_block = ""
        symbol_block << "<ul class=\"required-tags\">\n" if not symbols_only
        %w(rating category warning iswip).each do |w|
          css_class = eval("#{w}_class")
          title_string = eval("#{w}_string")
          symbol_block << "<li class=\"#{css_class}\">"
          symbol_block << link_to_help('symbols-key', link = image_tag( "#{css_class}.png", :alt => title_string, :title => title_string))
          symbol_block << "</li>\n"
        end
        symbol_block << "</ul>\n" if not symbols_only
        return symbol_block
      end

  def get_series_warnings_class(warning_tags)
    return "warning-yes" unless warning_tags
    none = true
    choosenotto = true
    warning_tags.map(&:name).each do |name|
      none = false if name != ArchiveConfig.WARNING_NONE_TAG_NAME
      choosenotto = false if name !=ArchiveConfig.WARNING_DEFAULT_TAG_NAME
    end
    return "warning-no" if none
    return "warning-choosenotto" if choosenotto
    "warning-yes"
  end

  def get_series_ratings_class(rating_tags)
    if rating_tags.blank?
      "rating-notrated"
    else
      names = rating_tags.collect(&:name)
      if names.include?(ArchiveConfig.RATING_EXPLICIT_TAG_NAME)
        "rating-explicit"
      elsif names.include?(ArchiveConfig.RATING_MATURE_TAG_NAME)
        "rating-mature"
      elsif names.include?(ArchiveConfig.RATING_TEEN_TAG_NAME)
        "rating-teen"
      elsif names.include?(ArchiveConfig.RATING_GENERAL_TAG_NAME)
        "rating-general-audience"
      else
        "rating-notrated"
      end
    end
  end

  def get_series_category_class(category_tags)
    if category_tags.blank?
      "category-none"
    elsif category_tags.length > 1
      "category-multi"
    else
      case category_tags.first.name
      when ArchiveConfig.CATEGORY_GEN_TAG_NAME
        "category-gen"
      when ArchiveConfig.CATEGORY_SLASH_TAG_NAME
        "category-slash"
      when ArchiveConfig.CATEGORY_HET_TAG_NAME
        "category-het"
      when ArchiveConfig.CATEGORY_FEMSLASH_TAG_NAME
        "category-femslash"
      when ArchiveConfig.CATEGORY_MULTI_TAG_NAME
        "category-multi"
      when ArchiveConfig.CATEGORY_OTHER_TAG_NAME
        "category-other"
      else
        "category-none"
      end
    end
  end

  #TODO: add complete attribute to series and adjust accordingly
  def get_series_complete_class(series)
    "category-none"
  end
  
  def series_blurb_tag_block(series)

    warnings_block = hide_warnings?(series) ? '<li class="warnings"><strong><span id="' + "series_#{series.id}_category_warning\">" + show_warnings_link(series) + '</span></strong></li>' :
      '<li class="warnings"><strong>' + 
        series.tags.select{|tag| tag.type == "Warning"}.sort.collect{|tag| link_to_tag(tag) }.join(ArchiveConfig.DELIMITER_FOR_OUTPUT + '</strong></li> <li class="warnings"><strong>') +
        '</strong></li>'

    pairings = series.tags.select{|tag| tag.type == "Pairing"}
    pairings_block = pairings.empty? ? nil : '<li class="pairing">' + 
        pairings.collect{|tag| link_to_tag(tag) }.join(ArchiveConfig.DELIMITER_FOR_OUTPUT + '</li> <li class="pairing">') +
        '</li>'
        
    characters = series.tags.select{|tag| tag.type == "Character"}
    character_block = characters.empty? ? nil : '<li class="character">' + 
        characters.collect{|tag| link_to_tag(tag)  }.join(ArchiveConfig.DELIMITER_FOR_OUTPUT + '</li> <li class="character">') +
        '</li>'
        
    freeforms = series.tags.select{|tag| tag.type == "Freeform"}
    freeform_block = freeforms.empty? ? nil :
      hide_freeform?(series) ? '<li class="freeform"><span id="' + "series_#{series.id}_category_freeform\"><strong>" + show_freeforms_link(series) + '</strong></span></li>' :
        '<li class="freeform">' +
        freeforms.collect{|tag| link_to_tag(tag) }.join(ArchiveConfig.DELIMITER_FOR_OUTPUT + '</li> <li class="freeform">') +
        '</li>'

    [warnings_block, pairings_block, character_block, freeform_block].compact.join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
  end
  
end
