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
  
  # Used in navigation link list in header
  def home_link
    logged_in? ? user_path(current_user) : root_path
  end
  
  # Can be used to check ownership of items
  def is_author_of?(item) 
    return false unless logged_in?
    if item.class == Work || item.class == Chapter || item.class == Series
      item.pseuds & current_user.pseuds != []
    elsif item.class == Bookmark
      current_user == item.user
    else
      current_user.pseuds.include?(item.pseud)
    end
  end
  
  def byline(creation)
    pseuds = ((creation.authors ||= []) + (creation.pseuds ||= [])).uniq 
    pseuds.collect { |pseud|
      link_to pseud.name, user_path(pseud.user), :class => "login story-author"
    }.join(', ')
  end

  # Currently, help files are static. We may eventually want to make these dynamic? 
  def link_to_help(help_entry, link = image_tag("question.png", :size => "20x20", :alt => h("More info").t))
    help_file = ""
    if Locale.active && Locale.active.language
      help_file = "#{ArchiveConfig.HELP_DIRECTORY}/#{Locale.active.language.code}/#{help_entry}.html"
    end
    
    unless !help_file.blank? && File.exists?("#{RAILS_ROOT}/public/#{help_file}")
      help_file = "#{ArchiveConfig.HELP_DIRECTORY}/#{help_entry}.html"
    end
    
    link_to_ibox link, :for => help_file
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
    result << "<div><select id='accessible_menu' name='url' >\n"
    # We'll sort the languages by their keyname rather than have all the non-arabic-character-set
    # ones end up at the end of the list.
    LANGUAGE_NAMES.sort {|a, b| a.first.to_s <=> b.first.to_s }.each do |locale, langname|
      langname = langname.titleize;   
      if Locale.active && Locale.active.language && locale == Locale.active.language.code
        result << "<option value=\"#{url_for :overwrite_params => {:locale => locale}}\" selected=\"selected\"><strong>#{langname} (#{locale})</strong></option>\n"
      else
        result << "<option value=\"#{url_for :overwrite_params => {:locale => locale}}\">#{langname} (#{locale})</option>\n"
      end
    end
    result << "</select></div>"
    result << "<noscript><p><input type=\"submit\" name=\"commit\" value=\"Go\" /></p></noscript>"
    result << "</form>"
    return result
  end  
  
  # Set a custom error-message handler that puts the errors on 
  # their respective fields instead of on the top of the page
  ActionView::Base.field_error_proc = Proc.new {|html_tag, instance|
    # don't put errors on the labels, duh
    if !html_tag.match(/label/)
      %(<span class='fieldWithErrors'>#{html_tag}</span>)
    elsif instance.error_message.kind_of?(Array)
      %(<span class='fieldWithErrors'>#{html_tag} <ul class='errorsList'><li>#{instance.error_message.join('</li><li>')}</li></ul></span>)
    else
      %(<span class='fieldWithErrors'>#{html_tag} #{instance.error_message}</span>)
    end
  }
  
  # A custom version of the error message display when something goes wrong 
  # with model validation. Currently this is actually just the same as the
  # default Rails method with translation included 
  def error_messages_for(*params)
    options = params.extract_options!.symbolize_keys
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    end
    error_count   = objects.inject(0) {|sum, obj| sum + obj.errors.count }
    unless error_count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'errorExplanation'
        end
      end
      options[:object_name] ||= params.first
      options[:header_message] = "We couldn't save this %s, sorry!"/options[:object_name].to_s.gsub('_', ' ').t unless options.include?(:header_message)
      options[:message] ||= 'Here are the problems we found:'.t unless options.include?(:message)
      error_messages = objects.sum {|obj| obj.errors.full_messages.map {|msg| content_tag(:li, msg) } }.join
      
      contents = ''
      contents << content_tag(options[:header_tag] || :h2, options[:header_message]) unless options[:header_message].blank?
      contents << content_tag(:p, options[:message]) unless options[:message].blank?
      contents << content_tag(:ul, error_messages)
      
      content_tag(:div, contents, html)
    else
          ''
    end
  end
 
  def translation_button
    if current_user.has_role? 'translator'
      return '<li> <a href="' + url_for(:controller => 'translation', :action => 'index') + '"' +
      image_tag("translation_button.gif", :alt => 'Link to translation page'.t, :border => 0) + "</a></li>"
    end
  end

  def sort_link(title, column, options = {})
    condition = options[:unless] if options.has_key?(:unless)
    sort_dir = params[:sort_direction] == 'ASC' ? 'DESC' : 'ASC'
    link_to_unless condition, title, request.parameters.merge( {:sort_column => column, :sort_direction => sort_dir} )
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


end # end of ApplicationHelper