# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include HtmlFormatter

	# Generates class names for the main div in the application layout
	def classes_for_main
    class_names = controller.controller_name + '-' + controller.action_name
    show_sidebar = ((@user || @admin_posts || @collection || show_wrangling_dashboard) && !@hide_dashboard)
    class_names += " sidebar" if show_sidebar
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
  
  def span_if_current(link_to_default_text, path)
    translation_name = "layout.header." + link_to_default_text.gsub(/\s+/, "_")
    link = link_to_unless_current(t(translation_name, :default => link_to_default_text), path)
    current_page?(path) ? "<span class=\"current\">#{link}</span>" : link
  end
  
  def limited_html_instructions
    h(t('plain_text', :default =>"Plain text with limited html")) + 
    link_to_help("html-help") + 
    "<br/><code>a, abbr, acronym, address, alt, b, big, blockquote, br, caption, center, cite, class, code, 
    col, colgroup, datetime, dd, del, dfn, div, dl, dt, em, h1, h2, h3, h4, h5, h6, height, hr, href, i, img, 
    ins, kbd, li, name, ol, p, pre, q, samp, small, span, src, strike, strong, sub, sup, table, tbody, td, 
    tfoot, th, thead, title, tr, tt, u, ul, var, width</code>"
  end
    
  # modified by Enigel Dec 13 08 to use pseud byline rather than just pseud name
  # in order to disambiguate in the case of identical pseuds
  # and on Feb 24 09 to sort alphabetically for great justice
  # and show only the authors when in preview_mode, unless they're empty
  def byline(creation)
    if creation.respond_to?(:anonymous?) && creation.anonymous?
      anon_byline = t('byline.anonymous', :default => "Anonymous") 
      anon_byline += " [" + non_anonymous_byline(creation) + "]" if logged_in_as_admin? || is_author_of?(creation)
      return anon_byline
    end
    non_anonymous_byline(creation)
  end
      
  def non_anonymous_byline(creation)
    pseuds = []
    pseuds << creation.authors if creation.authors
    pseuds << creation.pseuds if creation.pseuds && (!@preview_mode || creation.authors.blank?)
    pseuds = pseuds.flatten.uniq.sort
    
    archivists = {}
    if creation.is_a?(Work)
      external_creatorships = creation.external_creatorships.select {|ec| !ec.claimed?}
      external_creatorships.each do |ec|
        archivist_pseud = pseuds.select {|p| ec.archivist.pseuds.include?(p)}.first
        archivists[archivist_pseud] = ec.external_author_name.name
      end
    end
    
    pseuds.collect { |pseud| 
      archivists[pseud].nil? ? 
        link_to(pseud.byline, [pseud.user, pseud], :class => "login author") : 
        archivists[pseud] + 
          t('byline.archived_by', :default => "[archived by {{archivist}}]", 
            :archivist => link_to(pseud.byline, [pseud.user, pseud], :class => "login author"))
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
  
  # For setting the current locale
  def locales_menu    
    result = "<form action=\"" + url_for(:action => 'set', :controller => 'locales') + "\">\n" 
    result << "<div><select id=\"accessible_menu\" name=\"locale_id\" >\n"
    result << options_from_collection_for_select(@loaded_locales, :iso, :name, @current_locale.iso)
    result << "</select></div>"
    result << "<noscript><p><input type=\"submit\" name=\"commit\" value=\"Go\" /></p></noscript>"
    result << "</form>"
    return result
  end  
  
  # Generates sorting links for index pages, with column names and directions
  def sort_link(title, column=nil, options = {})
    condition = options[:unless] if options.has_key?(:unless)

    unless column.nil?
      if params[:sort_column] == column.to_s # is this the column that is currently doing the sorting?
        direction = params[:sort_direction] == 'ASC' ? 'DESC' : 'ASC'
        link_to_unless condition, (direction == 'ASC' ? '&#8593;  ' : '&#8595;  ') + title, 
          request.parameters.merge( {:sort_column => column, :sort_direction => direction} ), {:class => "current"}
      else
        link_to_unless condition, '&#8593;  ' + title,
          request.parameters.merge( {:sort_column => column, :sort_direction => 'ASC'} )
      end
    else
      link_to_unless params[:sort_column].nil?, title, url_for(:overwrite_params => {:sort_column => nil, :sort_direction => nil})
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

  # character counter helpers
  def countdown_field(field_id, update_id, max, options = {})
    function = "$('#{update_id}').innerHTML = (#{max} - $F('#{field_id}').length);"
    count_field_tag(field_id, function, options)
  end
  
  def count_field(field_id, update_id, options = {})
    function = "$('#{update_id}').innerHTML = $F('#{field_id}').length;"
    count_field_tag(field_id, function, options)
  end
  
  def count_field_tag(field_id, function, options = {})  
    out = javascript_tag function
    default_option = {:frequency => 0.25}
    options = default_option.merge(options)
    out += observe_field(field_id, options.merge(:function => function))
    return out
  end
  
  def generate_countdown_html(field_id, max) 
    generated_html = "<p class=\"character_counter\">"
    generated_html += "<span id=\"#{field_id}_counter\">?</span>"
    generated_html += countdown_field(field_id, field_id + "_counter", max) + " " + t('characters_left', :default => 'characters left')
    generated_html += "</p>"
    return generated_html
  end
  
  def autocomplete_text_field(fieldname, methodname="")
    "\n<span id=\"indicator_#{fieldname}\" style=\"display:none\">" +
    '<img src="/images/spinner.gif" alt="Working..." /></span>' +
    "\n<div class=\"auto_complete\" id=\"#{fieldname}_auto_complete\"></div>" +
    javascript_tag("new Ajax.Autocompleter('#{fieldname}', 
                            '#{fieldname}_auto_complete', 
                            '/autocomplete/#{methodname.blank? ? fieldname : methodname}', 
                            { 
                              indicator: 'indicator_#{fieldname}',
                              minChars: 3,
                              paramName: '#{fieldname}',
                              parameters: 'fieldname=#{fieldname}',
                              fullSearch: true,
                              tokens: ','
                            });")    
  end
  
  # Trying out a way of sending the tag type to the autocomplete
  # controller so that it can return the right class of results
  def autocomplete_text_field_with_type(object, fieldname)
    "\n<span id=\"indicator_#{fieldname}\" style=\"display:none\">" +
    '<img src="/images/spinner.gif" alt="Working..." /></span>' +
    "\n<div class=\"auto_complete\" id=\"#{fieldname}_auto_complete\"></div>" +
    javascript_tag("new Ajax.Autocompleter('#{fieldname}', 
                            '#{fieldname}_auto_complete', 
                            '/autocomplete/#{fieldname}', 
                            { 
                              indicator: 'indicator_#{fieldname}',
                              minChars: 2,
                              paramName: '#{fieldname}',
                              parameters: 'fieldname=#{fieldname}&type=#{object.type}',
                              fullSearch: true,
                              tokens: ','
                            });")    
  end

end # end of ApplicationHelper
