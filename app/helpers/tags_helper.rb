module TagsHelper
  
  # Takes an array of tags and returns a marked-up, comma-separated list
  def tag_link_list(tags)
    if tags.respond_to?(:collect)
      tags.collect{|tag| "<li>" + link_to_tag(tag) + "</li>"}.join(', ')
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
	  link_to tag.name, {:controller => :tags, :action => :show, :id => tag.name}, options
	end

	def link_to_tag_with_text(tag, link_text, options = {})
    options = {:class => "tag"}.merge(options)
	  link_to link_text, {:controller => :tags, :action => :show, :id => tag.name}, options
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
end
