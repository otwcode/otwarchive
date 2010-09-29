module TagsHelper
  
  # Takes an array of tags and returns a marked-up, comma-separated list
  def tag_link_list(tags)
    tags = tags.uniq.compact
    if !tags.blank? && tags.respond_to?(:collect)
      last_tag = tags.pop
      tag_list = tags.collect{|tag| "<li>" + link_to_tag(tag) + ", </li>"}.join
      tag_list + "<li>" + link_to_tag(last_tag) + "</li>"      
    end
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
  
  def wrangler_list(wranglers)
    if wranglers.blank?
      link_to "Sign Up", tag_wranglers_path
    else
      wranglers.collect(&:login).join(', ')
    end
  end

	def link_to_tag(tag, options = {})
    link_to_tag_with_text(tag, tag.is_a?(Warning) ? warning_display_name(tag.name) : tag.name, options)
	end

	def link_to_tag_with_text(tag, link_text, options = {})
    link_to_with_tag_class(@collection ? 
    {:controller => :tags, :action => :show, :id => tag, :collection_id => @collection} : 
    {:controller => :tags, :action => :show, :id => tag}, link_text, options)
	end

  # edit_tag_path is behaving badly since around the Rails 2.2.2 upgrade
	def link_to_edit_tag(tag, options = {})
    link_to_with_tag_class({:controller => :tags, :action => :edit, :id => tag}, tag.name, options)
	end

  def link_to_tag_works_with_text(tag, link_text, options = {})
    link_to_with_tag_class(@collection ? 
    {:controller => :works, :action => :index, :tag_id => tag, :collection_id => @collection} : 
    {:controller => :works, :action => :index, :tag_id => tag}, link_text, options)
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
      list << link_to(tt.titlecase, {:controller => tt, :action => :index, :tag_id => tag}) unless tt == controller_class
    end
    list.map{|li| "<li>" + li + "</li>"}.to_s 
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
    text = t('tags_helper.show_tag_type', :default => "Show %{tag_type}", :tag_type => (tag_type == 'freeforms' ? "additional tags" : tag_type))
    url = {:controller => 'tags', :action => 'show_hidden', :creation_type => creation.class.to_s, :creation_id => creation.id, :tag_type => tag_type }
    link_to text, :url => url, :method => :get, :remote => true
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
      span + tag.type + ": " + link_to_tag(tag) + " (#{tag.taggings_count})</span>"
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
    link_to link_text, {:controller => :comments, :action => :index, :tag_id => tag.name}
  end 
  
  def show_wrangling_dashboard
    %w(tag_wranglings tag_wranglers).include?(controller.controller_name) || 
    (can_wrangle? && controller.controller_name == 'tags') || 
    (@tag && controller.controller_name == 'comments')
  end
  
  # Returns a nested list of meta tags
  def meta_tag_tree(tag)
    meta_ul = ""
    unless tag.direct_meta_tags.empty?
      meta_ul << "<ul class='tags tree'>"
      tag.direct_meta_tags.each do |meta|
        meta_ul << "<li>" + link_to_tag(meta) + "</li>"
        unless meta.direct_meta_tags.empty?
          meta_ul << meta_tag_tree(meta)
        end
      end
      meta_ul << "</ul>"
    end
    meta_ul
  end
  
  # Returns a nested list of sub tags 
  def sub_tag_tree(tag)
    sub_ul = ""
    unless tag.direct_sub_tags.empty?
      sub_ul << "<ul class='tags tree'>"
      tag.direct_sub_tags.each do |sub|
        sub_ul << "<li>" + link_to_tag(sub) + "</li>"
        unless sub.direct_sub_tags.empty?
          sub_ul << sub_tag_tree(sub)
        end
      end
      sub_ul << "</ul>"
    end
    sub_ul
  end
  
  
  def blurb_tag_block(item, tag_groups=nil)
    item_class = item.class.to_s.underscore
    tag_groups ||= item.tag_groups
    categories = ['Warning', 'Relationship', 'Character', 'Freeform']
    last_tag = categories.collect { |c| tag_groups[c] }.flatten.compact.last
    tag_block = ""   
    
    categories.each do |category|
      if tags = tag_groups[category]
        class_name = category.downcase.pluralize
        if (class_name == "warnings" && hide_warnings?(item)) || (class_name == "freeforms" && hide_freeform?(item))
          open_tags = "<li class='#{class_name}' id='#{item_class}_#{item.id}_category_#{class_name}'><strong>"
          close_tags = "</strong></li>"
          delimiter = (class_name == 'freeforms' || last_tag.is_a?(Warning)) ? '' : ArchiveConfig.DELIMITER_FOR_OUTPUT
          tag_block <<  open_tags + show_hidden_tags_link(item, class_name) + delimiter + close_tags
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

  def get_title_string(tags, category_name = "")
    if tags && tags.size > 0
      tags.collect(&:name).join(", ")
    else
      category_name.blank? ? "" : "No" + " " + category_name
    end
  end
  
  def get_symbols_for(item, tag_groups=nil, symbols_only = false)
    tag_groups ||= item.tag_groups
    mappings = {}

    warnings = tag_groups['Warning']
    mappings[:warning] = {:class_name => get_warnings_class(warnings), :string =>  get_title_string(warnings)}
   
    ratings = tag_groups['Rating']
    rating = ratings.blank? ? nil : ratings.first
    mappings[:rating] = {:class_name => get_ratings_class(rating), :string =>  get_title_string(ratings, "rating")}
    
    categories = tag_groups['Category']
    mappings[:category] = {:class_name => get_category_class(categories), :string =>  get_title_string(categories, "category")}
    
    if item.class == Work
      iswip_string = item.is_wip ? "Work in Progress" : "Complete Work"
      iswip_class = item.is_wip ? "complete-no iswip" : "complete-yes iswip"
      mappings[:iswip] = {:class_name => iswip_class, :string =>  iswip_string}
    elsif item.class == ExternalWork
      mappings[:iswip] = {:class_name => 'external-work', :string =>  "External Work"}
    end

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

end
