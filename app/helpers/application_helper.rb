
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include HtmlCleaner

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
  
  def span_if_current(link_to_default_text, path)
    translation_name = "layout.header." + link_to_default_text.gsub(/\s+/, "_")
    link = link_to_unless_current(h(t(translation_name, :default => link_to_default_text)), path)
    current_page?(path) ? "<span class=\"current\">#{link}</span>".html_safe : link
  end
  
  def link_to_rss(link_to_feed)
    link_to (ts("Subscribe with RSS ") + image_tag("feed-icon-14x14.png", :size => "14x14", :alt => "")).html_safe , link_to_feed, :class => "rsslink"
  end
  
  def allowed_html_instructions(show_list = true)
    h(ts("Plain text with limited html")) + 
    link_to_help("html-help") + (show_list ? 
    "<br /><code>a, abbr, acronym, address, [alt], [axis], b, big, blockquote, br, caption, center, cite, [class], code, 
      col, colgroup, dd, del, dfn, div, dl, dt, em, h1, h2, h3, h4, h5, h6, [height], hr, [href], i, img, 
      ins, kbd, li, [name], ol, p, pre, q, s, samp, small, span, [src], strike, strong, sub, sup, table, tbody, td, 
      tfoot, th, thead, [title], tr, tt, u, ul, var, [width]</code>" : "").html_safe
  end
  
  
  def allowed_css_instructions
    h(ts("Limited CSS properties and values allowed")) + 
    link_to_help("css-help")
  end
  
  # This helper needs to be used in forms that may appear multiple times in the same
  # page (eg the comment form) since all the fields must have unique ids
  # see http://stackoverflow.com/questions/2425690/multiple-remote-form-for-on-the-same-page-causes-duplicate-ids
  def field_with_unique_id( form, field_type, object, field_name )
      field_id = "#{object.class.name.downcase}_#{object.id.to_s}_#{field_name.to_s}"
      form.send( field_type, field_name, :id => field_id )
  end
  
    
  # modified by Enigel Dec 13 08 to use pseud byline rather than just pseud name
  # in order to disambiguate in the case of identical pseuds
  # and on Feb 24 09 to sort alphabetically for great justice
  # and show only the authors when in preview_mode, unless they're empty
  def byline(creation, options={})
    if creation.respond_to?(:anonymous?) && creation.anonymous?
      anon_byline = h(ts("Anonymous"))
      if (logged_in_as_admin? || is_author_of?(creation)) && !options[:visibility] == 'public'
        anon_byline += " [".html_safe + non_anonymous_byline(creation) + "]".html_safe
        end
      return anon_byline
    end
    non_anonymous_byline(creation)
  end
      
  def non_anonymous_byline(creation)
    if creation.respond_to?(:author)
      creation.author
    else
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
            pseud_link(pseud) :
            archivists[pseud] + ts("[archived by") + pseud_link(pseud) + "]"
      }.join(', ').html_safe
    end
  end

  def pseud_link(pseud)
    if @downloading
      link_to(pseud.byline, user_pseud_path(pseud.user, pseud, :only_path => false))
    else
      link_to(pseud.byline, user_pseud_path(pseud.user, pseud), :class => "login author")
    end
  end

  # Currently, help files are static. We may eventually want to make these dynamic? 
  def link_to_help(help_entry, link = '<span class="symbol question"><span>?</span></span>'.html_safe)
    help_file = ""
    #if Locale.active && Locale.active.language
    #  help_file = "#{ArchiveConfig.HELP_DIRECTORY}/#{Locale.active.language.code}/#{help_entry}.html"
    #end
    
    unless !help_file.blank? && File.exists?("#{Rails.root}/public/#{help_file}")
      help_file = "#{ArchiveConfig.HELP_DIRECTORY}/#{help_entry}.html"
    end
    
    link_to_ibox(link, :for => help_file, :title => help_entry.split('-').join(' ').capitalize, :class => "symbol question").html_safe
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
  #       <%= flash_div :error, :warning, :notice %>
  # (These are the three varieties currently defined.) 
  #
  def flash_div *keys
    keys.collect { |key| 
      if flash[key] 
        content_tag(:div, h(flash[key]), :class => "flash #{key}") if flash[key] 
      end
    }.join.html_safe
  end

  # Gets an error for a given field if it exists. 
  def flash_field(fieldname)
    if flash[fieldname]
      content_tag(:span, h(flash[fieldname]), :class => "fielderror").html_safe
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
      current_column = (params[:sort_column] == column.to_s) || params[:sort_column].blank? && options[:sort_default]
      css_class = current_column ? "current" : nil
      if current_column # explicitly or implicitly doing the existing sorting, so we need to toggle
        if params[:sort_direction]
          direction = params[:sort_direction].to_s.upcase == 'ASC' ? 'DESC' : 'ASC'
        else 
          direction = options[:desc_default] ? 'ASC' : 'DESC'
        end
      else
        direction = options[:desc_default] ? 'DESC' : 'ASC'
      end
      link_to_unless condition, ((direction == 'ASC' ? '&#8593;<span class="landmark">ascending</span>&#160;' : '&#8595;<span class="landmark">descending</span>&#160;') + title).html_safe, 
          request.parameters.merge( {:sort_column => column, :sort_direction => direction} ), {:class => css_class}
    else
      link_to_unless params[:sort_column].nil?, title, url_for(params.merge :sort_column => nil, :sort_direction => nil)
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
  
  # check for pages that allow tiny_mce before loading the massive javascript
  def allow_tinymce?(controller)
    %w(admin_posts archive_faqs known_issues chapters works).include?(controller.controller_name) &&
      %w(new edit update).include?(controller.action_name)
  end

  def params_without(name)
    params.reject{|k,v| k == name}
  end

  # character counter helpers
  # countdown should count newlines as "\r\n" combos, regardless of the OS and browsers' whim;
  # so we count any single "\n"s and "\r"s as "\r\n", which is what they'd end up as in the db anyway
  def countdown_field(field_id, update_id, max, options = {})
    function = "value = $F('#{field_id}'); value=(value.replace(/\\r\\n/g,'\\n')).replace(/\\r|\\n/g,'\\r\\n'); $('#{update_id}').innerHTML = (#{max} - value.length);"
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
    generated_html = "<p class=\"character_counter\">".html_safe
    generated_html += "<span id=\"#{field_id}_counter\">?</span>".html_safe
    generated_html += countdown_field(field_id, field_id + "_counter", max) + " ".html_safe + h(ts('characters left'))
    generated_html += "</p>".html_safe
    return generated_html
  end
  
  # returns the default autocomplete attributes, all of which can be overridden
  # note: we do this and put the message defaults here so we can use translation on them
  def autocomplete_options(method, options={})
    {      
      :class => "autocomplete",
      :autocomplete_method => "/autocomplete/#{method}",
      :autocomplete_hint_text => ts("Start typing for suggestions!"),
      :autocomplete_no_results_text => ts("(No suggestions found)"),
      :autocomplete_min_chars => 1,
      :autocomplete_searching_text => ts("Searching...")
    }.merge(options)
  end
    
  # see http://asciicasts.com/episodes/197-nested-model-form-part-2
  def link_to_add_section(linktext, form, nested_model_name, partial_to_render, locals = {})
    new_nested_model = form.object.class.reflect_on_association(nested_model_name).klass.new
    child_index = "new_#{nested_model_name}"
    rendered_partial_to_add = 
      form.fields_for(nested_model_name, new_nested_model, :child_index => child_index) {|child_form|
        render(:partial => partial_to_render, :locals => {:form => child_form, :index => child_index}.merge(locals))
      }
    link_to_function(linktext, "add_section(this, \"#{nested_model_name}\", \"#{escape_javascript(rendered_partial_to_add)}\")", :id => "add_section")
  end

  def link_to_remove_section(linktext, form, class_of_section_to_remove="removeme")
    form.hidden_field(:_destroy) + "\n" +
    link_to_function(linktext, "remove_section(this, \"#{class_of_section_to_remove}\")")
  end
  
  def time_in_zone(time, zone=nil, user=User.current_user)
    zone = ((user && user.is_a?(User) && user.preference.time_zone) ? user.preference.time_zone : Time.zone.name) unless zone
    time_in_zone = time.in_time_zone(zone)
    time_in_zone_string = time_in_zone.strftime('<abbr class="day" title="%A">%a</abbr> <span class="date">%d</span> 
                                                 <abbr class="month" title="%B">%b</abbr> <span class="year">%Y</span> 
                                                 <span class="time">%I:%M%p</span>').html_safe + 
                                          " <abbr class=\"timezone\" title=\"#{zone}\">#{time_in_zone.zone}</abbr> ".html_safe
    
    user_time_string = "".html_safe
    if user.is_a?(User) && user.preference.time_zone
      if user.preference.time_zone != zone
        user_time = time.in_time_zone(user.preference.time_zone)
        user_time_string = "(".html_safe + user_time.strftime('<span class="time">%I:%M%p</span>').html_safe +
          " <abbr class=\"timezone\" title=\"#{user.preference.time_zone}\">#{user_time.zone}</abbr>)".html_safe
      elsif !user.preference.time_zone
        user_time_string = link_to ts("(set timezone)"), user_preferences_path(user)
      end
    end
    
    time_in_zone_string + user_time_string
  end
  
  def mailto_link(user, options={})
    "<a href=\"mailto:#{h(user.email)}?subject=[#{ArchiveConfig.APP_NAME}]#{options[:subject]}\" class=\"mailto\">
      <img src=\"/images/envelope_icon.gif\" alt=\"#{h(user.login)}'s email\">
    </a>".html_safe
  end
  
  # toggle an options (scrollable checkboxes) section of a form to show all of the options
  def options_toggle(options_id, options_size)
    toggle_show = content_tag(:a, ts("Show all %{options_size} options", :options_size => options_size), 
                              :class => "toggle", :id => "#{options_id}_show", 
                              :onclick => "$('#{options_id}').writeAttribute('class', 'options all');
                                           $('#{options_id}_hide').show();
                                           this.hide();")

    toggle_hide = content_tag(:a, ts("Collapse options"), :style => "display: none;",
                              :class => "toggle", :id => "#{options_id}_hide", 
                              :onclick => "$('#{options_id}').writeAttribute('class', 'options#{options_size > (ArchiveConfig.OPTIONS_TO_SHOW *   3) ? ' many' : ''}');
                                           $('#{options_id}_show').show();
                                           this.hide();")

    toggle = content_tag(:p, toggle_show + "\n".html_safe + toggle_hide)
  end

  # create a scrollable checkboxes section for a form
  # form: the form this is being created in
  # fieldname: the fieldname for the field being filled in by the checkboxes -- eg "work[tagnames][]"
  # id: the base id for the checkbox fields -- eg "work_tagnames"
  # options: the array of options (which should be objects of some sort)
  # options_checked_method: a method that can be run on the object of the form to get back a list 
  #         of currently-set options
  # option_name_method: a method that can be run on each individual option to get its pretty name for labelling
  #
  # See the prompt_form in challenge signups for example of usage
  def options_section(form, fieldname, id, options, options_checked_method, option_name_method="name", option_value_method="id", option_disabled)
    size = options.size
    options_id = "#{id}_options"
    
    options_checkboxes = options.map do |option|
      checkbox_id = "#{id}_#{option.id}"
      checkbox_is_checked = form.object.send(options_checked_method).include?(option)
      checkbox_name = option.send(option_name_method)
      checkbox_value = option.send(option_value_method)
      checkbox_and_label = label_tag checkbox_id do 
        if option_disabled == "false"
          check_box_tag(fieldname, checkbox_value, checkbox_is_checked, :id => checkbox_id) + checkbox_name
        else
          check_box_tag(fieldname, checkbox_value, checkbox_is_checked, :id => checkbox_id, :disabled => "true") + checkbox_name
        end
      end
      content_tag(:li, checkbox_and_label, :class => cycle("odd", "even", :name => "tigerstriping"))
    end.join("\n").html_safe

    # reset the tiger striping
    reset_cycle("tigerstriping")

    # if there are only a few options, don't show the scrolling and the toggle
    if size <= ArchiveConfig.OPTIONS_TO_SHOW
      content_tag(:ul, options_checkboxes, :id => options_id) + hidden_field_tag(fieldname, " ")
    else
      # return the toggle, the options in a scrollable field, and a hidden field 
      # to ensure the results are sent even if the user has unchecked all the options
      options_toggle(options_id, size) + 
        "\n".html_safe +
        content_tag(:ul, options_checkboxes, :id => options_id, 
                    :class => "options#{size > (ArchiveConfig.OPTIONS_TO_SHOW * 3) ? ' many' : ''}") + 
        "\n".html_safe +
        hidden_field_tag(fieldname, " ")
    end
  end
  
end # end of ApplicationHelper
