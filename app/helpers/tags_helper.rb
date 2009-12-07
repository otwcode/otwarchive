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

  def tag_cloud(tags, classes)
    max, min = 0, 0
    tags.each { |t|
      max = t.taggings_count.to_i if t.taggings_count.to_i > max
      min = t.taggings_count.to_i if t.taggings_count.to_i < min
    }

    divisor = ((max - min) / classes.size) + 1

    tags.each { |t|
      yield t, classes[(t.taggings_count - min) / divisor]
    }
  end

  # Displays a list of links for navigating the tag wrangling section of the site
  def tag_wrangler_footer
    render :partial => 'tag_wranglings/footer'
  end

  def tag_wrangler_header
    render :partial => 'tag_wranglings/header'
  end

	# Adds a consistent class name to tags
	def link_to_tag(tag, options = {})
    options = {:class => "tag"}.merge(options)
	  link_to tag.type == "Warning" ? warning_display_name(tag.name) : tag.name, {:controller => :tags, :action => :show, :id => tag}, options
	end

	def link_to_tag_with_text(tag, link_text, options = {})
    options = {:class => "tag"}.merge(options)
	  link_to link_text, {:controller => :tags, :action => :show, :id => tag}, options
	end

	# Adds a consistent class name to tags
  # edit_tag_path is behaving badly since around the Rails 2.2.2 upgrade
	def link_to_edit_tag(tag, options = {})
    options = {:class => "tag"}.merge(options)
    link_to tag.name, {:controller => :tags, :action => :edit, :id => tag}, options
	end

  def link_to_tag_works_with_text(tag, link_text, options = {})
    options = {:class => "tag"}.merge(options)
	  link_to link_text, {:controller => :works, :action => :index, :tag_id => tag}, options
	end

  def can_wrangle?
    logged_in_as_admin? || ( current_user.is_a?(User) && current_user.is_tag_wrangler? )
  end
  
  def taggable_list(tag, controller_class)
    taggable_things = ["bookmarks", "works"]
    list = []
    taggable_things.each do |tt|
      list << link_to(tt.titlecase, {:controller => tt, :action => :index, :tag_id => tag}) unless tt == controller_class
    end
    "<ul class=""taggable_strip""><li>" + t("see_also", :default => "See also: ") + "</li>" + list.map{|li| "<li>" + li + "</li>"}.to_s + "</ul>"
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
end
