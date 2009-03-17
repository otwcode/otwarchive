# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include HtmlFormatter

	# Generates class names for the main div in the application layout
	def classes_for_main
		class_names = controller.controller_name + '-' + controller.action_name
		class_names += " sidebar" unless @user.blank? || @hide_dashboard
		class_names
	end

  # A more gracefully degrading link_to_remote.
  def link_to_remote(name, options = {}, html_options = {})
    unless html_options[:href]
      html_options[:href] = url_for(options[:url])
    end
    
    link_to_function(name, remote_function(options), html_options)
  end
  
  # just really common and hate trying to remember the damn formatting
  # this returns: hour:minuteAM/PM Timezone Mon/Tue day# January/February 4-digit Year
  # can be used with strftime or Localize
  def common_timestring
    "%I:%M%p %Z %a %d %B %Y"
  end
  
  # Used in navigation link list in header
  def home_link
    if logged_in? 
			text = "my home"
			link = user_path(current_user) 
		else
			text = "home"
			link = root_path
		end
		link_to_unless_current "<span>" + text + "</span>", link
  end
    
  # modified by Enigel Dec 13 08 to use pseud byline rather than just pseud name
  # in order to disambiguate in the case of identical pseuds
  # and on Feb 24 09 to sort alphabetically for great justice
  # and show only the authors when in preview_mode, unless they're empty
  def byline(creation)
    pseuds = []
    pseuds << creation.authors if creation.authors
    pseuds << creation.pseuds if creation.pseuds && (!@preview_mode || creation.authors.empty?)
    pseuds.flatten.uniq.sort.collect { |pseud|
      link_to pseud.byline, user_pseud_path(pseud.user, pseud.id), :class => "login author"
    }.join(', ')
  end

  # Currently, help files are static. We may eventually want to make these dynamic? 
  def link_to_help(help_entry, link = '<span class="symbol question"><span>?</span></span>')
    help_file = ""
    #if Locale.active && Locale.active.language
    #  help_file = "#{ArchiveConfig.HELP_DIRECTORY}/#{Locale.active.language.code}/#{help_entry}.html"
    #end
    
    unless !help_file.blank? && File.exists?("#{RAILS_ROOT}/public/#{help_file}")
      help_file = "#{ArchiveConfig.HELP_DIRECTORY}/#{help_entry}.html"
    end
    
    link_to_ibox link, :for => help_file, :title => help_entry.split('-').join(' ').capitalize, :class => "symbol question"
  end
  
  # Inserts the flash alert messages for flash[:key] wherever 
  #       <%= flash_div :key %> 
  # is placed in the views. That is, if a controller or model sets
  #       flash[:error] = "OMG ERRORZ AIE"
  # or
  #       flash.now[:error] = "OMG ERRORZ AIE"
  #
  # then that error will appear in the view where you have
  #       <%= flash_div :error %>
  #
  # The resulting HTML will look like this:
  #       <div class="flash error">OMG ERRORZ AIE</div>
  #
  # The CSS classes are specified in archive_core.css.
  #
  # You can also have multiple possible flash alerts in a single location with:
  #       <%= flash_div :error, :warning, :notice -%>
  # (These are the three varieties currently defined.) 
  #
  def flash_div *keys
    keys.collect { |key| 
      if flash[key] 
        content_tag(:div, flash[key], :class => "flash #{key}") if flash[key] 
      end
    }.join
  end

  # Gets an error for a given field if it exists. 
  def flash_field(fieldname)
    if flash[fieldname]
      content_tag(:span, flash[fieldname], :class => "fielderror")
    end
  end
  
  # Create a nicer language menu than the Click-To-Globalize default
  def languages_menu    
    result = "<form action=\"" + url_for(:action => 'set', :controller => 'locale') + "\">\n" 
    result << "<div><select id='accessible_menu' name='locale' >\n"
    result << options_from_collection_for_select(@loaded_locales, :short, :name, @current_locale.short)
    result << "</select></div>"
    result << "<noscript><p><input type=\"submit\" name=\"commit\" value=\"Go\" /></p></noscript>"
    result << "</form>"
    return result
  end  
  
  def sort_link(title, column=nil, options = {})
    condition = options[:unless] if options.has_key?(:unless)

    unless column.nil?
      sort_dir_sym = "sort_direction_for_#{column}".to_sym
      sort_dir = params[sort_dir_sym] == 'ASC' ? 'DESC' : 'ASC'
      link_to_unless condition, image_tag(sort_dir == 'ASC' ? 'arrow-up.png' : 'arrow-down.png') + " " + title, 
        request.parameters.merge( {:sort_column => column, sort_dir_sym => sort_dir} )
    else
      link_to_unless params[:sort_column].nil?, title, url_for(:overwrite_params => {:sort_column => nil})
    end
  end

  ## Allow use of tiny_mce WYSIWYG editor
  def use_tinymce
    @content_for_tinymce = "" 
    content_for :tinymce do
      javascript_include_tag "tiny_mce/tiny_mce"
    end
    @content_for_tinymce_init = "" 
    content_for :tinymce_init do
      javascript_include_tag "mce_editor"
    end
  end  

  def params_without(name)
    params.reject{|k,v| k == name}
  end

end # end of ApplicationHelper
