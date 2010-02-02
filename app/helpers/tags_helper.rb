module TagsHelper
  
  # Takes an array of tags and returns a marked-up, comma-separated list
  def tag_link_list(tags)
    if tags.respond_to?(:collect)
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

	def link_to_tag(tag, options = {})
    link_to_tag_with_text(tag, tag.type == "Warning" ? warning_display_name(tag.name) : tag.name, options)
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

  # Link to show warnings if they're currently hidden
  def show_warnings_link(creation)
    link_to_remote "Show warnings",
      :url => {:controller => 'tags', :action => 'show_hidden', :creation_type => creation.class.to_s, :creation_id => creation.id },
      :method => :get
  end
  
  # Link to show tags if they're currently hidden
  def show_freeforms_link(creation)
    link_to_remote "Show tags",
      :url => {:controller => 'tags', :action => 'show_hidden_freeforms', :creation_type => creation.class.to_s, :creation_id => creation.id },
      :method => :get
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
    span = tag.canonical? ? "<span class='canonical'>" : "<span>"
    span + tag.type + ": " + link_to_tag(tag) + " (#{tag.taggings_count})</span>"
  end
    
end