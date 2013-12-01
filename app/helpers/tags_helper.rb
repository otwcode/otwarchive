module TagsHelper
  
  def tag_type_label(tag_type)
    case tag_type
    when 'tag'
      "Bookmarker's Tags"
    when 'freeform'
      "Additional Tags"
    else
      tag_type.capitalize.pluralize
    end
  end

  # Takes an array of tags and returns a marked-up, comma-separated list of links to them
  def tag_link_list(tags, link_to_works=false)
    tags = tags.uniq.compact.map {|tag| content_tag(:li, link_to_works ? link_to_tag_works(tag) : link_to_tag(tag))}.join.html_safe
  end
  
  def description(tag)
    tag.name + " (" + tag.class.name + ")"
  end

  # Adds the appropriate css classes for the tag index page
  def tag_cloud(tags, classes)
    max, min = 0, 0
    tags.each { |t|
      max = t.count.to_i if t.count.to_i > max
      min = t.count.to_i if t.count.to_i < min
    }

    divisor = ((max - min) / classes.size) + 1

    tags.each { |t|
      yield t, classes[(t.count.to_i - min) / divisor]
    }
  end

  # Displays a list of links for navigating the tag wrangling section of the site
  def tag_wrangler_footer
    render :partial => 'tag_wranglings/footer'
  end

  def wrangler_list(wranglers, tag)
    if wranglers.blank?
      if @tag[:type] == 'Fandom'
        sign_up_fandoms = tag.name
      elsif Tag::USER_DEFINED.include?(@tag.class.name) && !tag.fandoms.blank?
        sign_up_fandoms = tag.fandoms.collect(&:name).join(', ')
      end
      link_to "Sign Up", tag_wranglers_path(:sign_up_fandoms => sign_up_fandoms)
    else
      wranglers.collect(&:login).join(', ')
    end
  end

  def link_to_tag(tag, options = {})
    link_to_tag_with_text(tag, tag.is_a?(Warning) ? warning_display_name(tag.name) : tag.name, options)
  end

  def link_to_tag_works(tag, options = {})
    link_to_tag_works_with_text(tag, tag.is_a?(Warning) ? warning_display_name(tag.name) : tag.name, options)
  end
  
  def link_to_tag_with_text(tag, link_text, options = {})
    link_to_with_tag_class(@collection ? collection_tag_url(@collection, tag) : tag_url(tag), link_text, options)
  end

  def link_to_edit_tag(tag, options = {})
    link_to_with_tag_class(edit_tag_path(tag), tag.name, options)
  end
  
  def tag_with_link_to_edit(tag, options = {})
    options.reverse_merge!({:target => "_blank"})
    content_tag(:span, tag.name, :class=>"tag") + " ".html_safe + link_to_with_tag_class(edit_tag_path(tag), "(<span class=\"edit\">edit</span> &#x2710;)".html_safe, options)
  end

  def link_to_tag_works_with_text(tag, link_text, options = {})
    link_to_with_tag_class(@collection ? collection_tag_works_url(@collection, tag) : tag_works_url(tag), link_text, options)
  end

  # the label on checkboxes to remove tag associations
  # currently blank per wrangler request, can be changed to different label as desired
  def remove_tag_association_label(tag)
    "".html_safe
  end

  # Adds the "tag" classname to links (for tag links)
  def link_to_with_tag_class(path, text, options)
    options[:class] ? options[:class] << " tag" : options[:class] = "tag"
    link_to text, path, options
  end

  # Used on tag edit page
  def tag_category_name(tag_type)
    tag_type == "Merger" ? "Synonyms" : tag_type.pluralize
  end

  # Should the current user be able to access tag wrangling pages?
  def can_wrangle?
    logged_in_as_admin? || (current_user.is_a?(User) && current_user.is_tag_wrangler?)
  end

  def taggable_list(tag, controller_class)
    taggable_things = ["bookmarks", "works"]
    list = []
    taggable_things.each do |tt|
      list << link_to(h(ts(tt.titlecase)), {:controller => tt, :action => :index, :tag_id => tag}) unless tt == controller_class
    end
    list.map{|li| "<li>" + li + "</li>"}.join.html_safe
  end

  # Determines whether or not to display warnings for a creation
  def hide_warnings?(creation)
    current_user.is_a?(User) && current_user.preference && current_user.preference.hide_warnings? && !current_user.is_author_of?(creation)
  end

  # Determines whether or not to display freeform tags for a creation
    def hide_freeform?(creation)
    current_user.is_a?(User) && current_user.preference && current_user.preference.hide_freeform? && !current_user.is_author_of?(creation)
  end

  # Link to show tags if they're currently hidden
  def show_hidden_tags_link(creation, tag_type)
    text = ts("Show %{tag_type}", :tag_type => (tag_type == 'freeforms' ? "additional tags" : tag_type))
    url = {:controller => 'tags', :action => 'show_hidden', :creation_type => creation.class.to_s, :creation_id => creation.id, :tag_type => tag_type }
    link_to text, url, :remote => true
  end

  # Makes filters show warnings display name
  def label_for_filter(type, tag_info)
    name = (type == "Warning") ? warning_display_name(tag_info[:name]) : tag_info[:name]
    name + " (#{tag_info[:count]})"
  end

  # Changes display name of warnings in works blurb
  def warning_display_name(name)
    case name
    when ArchiveConfig.WARNING_DEFAULT_TAG_NAME
      return ArchiveConfig.WARNING_DEFAULT_TAG_DISPLAY_NAME ? ArchiveConfig.WARNING_DEFAULT_TAG_DISPLAY_NAME.to_s : name
    when ArchiveConfig.WARNING_NONE_TAG_NAME
      return ArchiveConfig.WARNING_NONE_TAG_DISPLAY_NAME ? ArchiveConfig.WARNING_NONE_TAG_DISPLAY_NAME.to_s : name
    when ArchiveConfig.WARNING_SOME_TAG_NAME
      return ArchiveConfig.WARNING_SOME_TAG_DISPLAY_NAME ? ArchiveConfig.WARNING_SOME_TAG_DISPLAY_NAME.to_s : name
    when ArchiveConfig.WARNING_VIOLENCE_TAG_NAME
      return ArchiveConfig.WARNING_VIOLENCE_TAG_DISPLAY_NAME ? ArchiveConfig.WARNING_VIOLENCE_TAG_DISPLAY_NAME.to_s : name
    when ArchiveConfig.WARNING_DEATH_TAG_NAME
      return ArchiveConfig.WARNING_DEATH_TAG_DISPLAY_NAME ? ArchiveConfig.WARNING_DEATH_TAG_DISPLAY_NAME.to_s : name
    when ArchiveConfig.WARNING_NONCON_TAG_NAME
      return ArchiveConfig.WARNING_NONCON_TAG_DISPLAY_NAME ? ArchiveConfig.WARNING_NONCON_TAG_DISPLAY_NAME.to_s : name
    when ArchiveConfig.WARNING_CHAN_TAG_NAME
      return ArchiveConfig.WARNING_CHAN_TAG_DISPLAY_NAME ? ArchiveConfig.WARNING_CHAN_TAG_DISPLAY_NAME.to_s : name
    else
      return name
    end
  end

  # Individual results for a tag search
  def tag_search_result(tag)
    if tag
      span = tag.canonical? ? "<span class='canonical'>" : "<span>"
      span += tag.type + ": " + link_to_tag(tag) + " (#{tag.taggings_count})</span>"
      span.html_safe
    end
  end

  def tag_comment_link(tag)
    count = tag.total_comments.count.to_s
    if count == "0"
      last_comment = ""
    else
      last_comment = " (last comment: " + tag.total_comments.find(:first, :order => 'created_at DESC').created_at.to_s + ")"
    end
    link_text = count + " comments" + last_comment
    link_to link_text, {:controller => :comments, :action => :index, :tag_id => tag}
  end

  def show_wrangling_dashboard
    can_wrangle? && 
    (%w(tags tag_wranglings tag_wranglers tag_wrangling_requests unsorted_tags).include?(controller.controller_name) ||
    (@tag && controller.controller_name == 'comments'))
  end

  # Returns a nested list of meta tags 
  def meta_tag_tree(tag)
    meta_ul = "".html_safe
    unless tag.direct_meta_tags.empty?
      tag.direct_meta_tags.each do |meta|
        meta_ul += content_tag(:li, link_to_tag(meta))
        unless meta.direct_meta_tags.empty?
          meta_ul += content_tag(:li, meta_tag_tree(meta))
        end
      end
    end
    content_tag(:ul, meta_ul, :class => 'tags tree index')
  end

  # Returns a nested list of sub tags
  def sub_tag_tree(tag)
    sub_ul = ""
    unless tag.direct_sub_tags.empty?
      sub_ul << "<ul class='tags tree index'>"
      tag.direct_sub_tags.each do |sub|
        sub_ul << "<li>" + link_to_tag(sub) + "</li>"
        unless sub.direct_sub_tags.empty?
          sub_ul << sub_tag_tree(sub)
        end
      end
      sub_ul << "</ul>"
    end
    sub_ul.html_safe
  end


  def blurb_tag_block(item, tag_groups=nil)
    item_class = item.class.to_s.underscore
    tag_groups ||= item.tag_groups
    categories = ['Warning', 'Relationship', 'Character', 'Freeform']
    tag_block = ""

    categories.each do |category|
      if tags = tag_groups[category]
        class_name = category.downcase.pluralize
        if (class_name == "warnings" && hide_warnings?(item)) || (class_name == "freeforms" && hide_freeform?(item))
          open_tags = "<li class='#{class_name}' id='#{item_class}_#{item.id}_category_#{class_name}'><strong>"
          close_tags = "</strong></li>"
          tag_block <<  open_tags + show_hidden_tags_link(item, class_name) + close_tags
        elsif class_name == "warnings"
          open_tags = "<li class='#{class_name}'><strong>"
          close_tags = "</strong></li>"
          link_array = tags.collect{|tag| link_to_tag_works(tag)}
          tag_block <<  open_tags + link_array.join("</strong></li> <li class='#{class_name}'><strong>") + close_tags
        else
          link_array = tags.collect{|tag| link_to_tag_works(tag)}
          tag_block << "<li class='#{class_name}'>" + link_array.join("</li> <li class='#{class_name}'>") + '</li>'
        end
      end
    end
    tag_block.html_safe
  end

  def get_title_string(tags, category_name = "")
    if tags && tags.size > 0
      tags.collect(&:name).join(", ")
    elsif tags.blank? && category_name.blank?
     "Choose Not To Use Archive Warnings"
    else
      category_name.blank? ? "" : "No" + " " + category_name
    end
  end

  # produce our spiffy pretty block of tag symbols
  def get_symbols_for(item, tag_groups=nil, symbols_only = false)
    symbol_block = []
    symbol_block << "<ul class=\"required-tags\">" unless symbols_only

    # split up the item's tags into groups based on type
    tag_groups ||= item.tag_groups

    ratings = tag_groups['Rating']
    symbol_block << get_symbol_link(get_ratings_class(ratings), get_title_string(ratings, "rating"))

    warnings = tag_groups['Warning']
    symbol_block << get_symbol_link(get_warnings_class(warnings), get_title_string(warnings))

    categories = tag_groups['Category']
    symbol_block << get_symbol_link(get_category_class(categories), get_title_string(categories, "category"))

    if [Work, Series].include?(item.class)
      if item.complete?
        symbol_block << get_symbol_link( "complete-yes iswip" , "Complete #{item.class.to_s}")
      else
        symbol_block << get_symbol_link( "complete-no iswip", "#{item.class.to_s} in Progress" )
      end
    elsif item.class == ExternalWork
      symbol_block << get_symbol_link('external-work', "External Work")
    elsif item.is_a?(Prompt)
      if item.unfulfilled?
        symbol_block << get_symbol_link( "complete-no iswip", "#{item.class.to_s} Unfulfilled" )
      else
        symbol_block << get_symbol_link("complete-yes iswip", "#{item.class.to_s} Fulfilled" )
      end
    end

    symbol_block << "</ul>" unless symbols_only
    return symbol_block.join("\n").html_safe
  end

  def get_symbol_link(css_class, title_string)
    content_tag(:li, link_to_help('symbols-key', link = ("<span class=\"#{css_class}\" title=\"#{title_string}\"><span class=\"text\">" + title_string + "</span></span>").html_safe))
  end

  # return the right warnings class
  def get_warnings_class(warning_tags = [])
    if warning_tags.blank? # for testing
      "warning-choosenotto warnings"
    elsif warning_tags.size == 1 && warning_tags.first.name == ArchiveConfig.WARNING_NONE_TAG_NAME
      # only one tag and it says "no warnings"
      "warning-no warnings"
    elsif warning_tags.size == 1 && warning_tags.first.name == ArchiveConfig.WARNING_DEFAULT_TAG_NAME
      # only one tag and it says choose not to warn
      "warning-choosenotto warnings"
    elsif warning_tags.size == 2 && ((warning_tags.first.name == ArchiveConfig.WARNING_DEFAULT_TAG_NAME && warning_tags.second.name == ArchiveConfig.WARNING_NONE_TAG_NAME) || (warning_tags.first.name == ArchiveConfig.WARNING_NONE_TAG_NAME && warning_tags.second.name == ArchiveConfig.WARNING_DEFAULT_TAG_NAME))
      # two tags and they are "choose not to warn" and "no archive warnings apply" in either order
      "warning-choosenotto warnings"
    else
      "warning-yes warnings"
    end
  end

  def get_ratings_class(rating_tags = [])
    if rating_tags.blank? # for testing
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

end
