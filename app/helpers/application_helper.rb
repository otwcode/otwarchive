
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include HtmlCleaner

  # Generates class names for the main div in the application layout
  def classes_for_main
    class_names = controller.controller_name + '-' + controller.action_name
    
    show_sidebar = ((@user || @admin_posts || @collection || show_wrangling_dashboard) && !@hide_dashboard)
    class_names += " dashboard" if show_sidebar
    
    if page_has_filters?
      class_names += " filtered"
    end
    
    if %w(abuse_reports feedbacks known_issues).include?(controller.controller_name)
      class_names = "system support " + controller.controller_name + ' ' + controller.action_name
    end
    if controller.controller_name == "archive_faqs"
      class_names = "system support faq " + controller.action_name
    end
    if controller.controller_name == "home"
      class_names = "system docs " + controller.action_name
    end
    
    class_names
  end
  
  def page_has_filters?
    @facets.present? || (controller.action_name == 'index' && controller.controller_name == 'collections') || (controller.action_name == 'unassigned' && controller.controller_name == 'fandoms')
  end

  # A more gracefully degrading link_to_remote.
  def link_to_remote(name, options = {}, html_options = {})
    unless html_options[:href]
      html_options[:href] = url_for(options[:url])
    end
    
    link_to_function(name, remote_function(options), html_options)
  end

  # This is used to make the current page we're on (determined by the path or by the specified condition) is a span with class "current" 
  def span_if_current(link_to_default_text, path, condition=nil)
    is_current = condition.nil? ? current_page?(path) : condition
    text = ts(link_to_default_text)
    is_current ? "<span class=\"current\">#{text}</span>".html_safe : link_to(text, path)
  end
  
  def link_to_rss(link_to_feed)
    link_to content_tag(:span, ts("Subscribe to the feed")), link_to_feed, :title => "subscribe to feed", :class => "rss"
  end
  
  #1: default shows just the link to help
  #2: show_text = true: shows "plain text with limited html" and link to help
  #3 show_list = true: plain text and limited html, link to help, list of allowed html
  def allowed_html_instructions(show_list = false, show_text=true)
    (show_text ? h(ts("Plain text with limited HTML")) : ''.html_safe) + 
    link_to_help("html-help") + (show_list ? 
    "<code>a, abbr, acronym, address, [alt], [axis], b, big, blockquote, br, caption, center, cite, [class], code, 
      col, colgroup, dd, del, dfn, [dir], div, dl, dt, em, h1, h2, h3, h4, h5, h6, [height], hr, [href], i, img,
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
      anon_byline = ts("Anonymous")
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
          archivists[archivist_pseud] = ec.author_name
        end
      end
    
      pseuds.collect { |pseud| 
        archivists[pseud].nil? ? 
            pseud_link(pseud) :
            archivists[pseud] + " [" + ts("archived by %{name}", :name => pseud_link(pseud)) + "]"
      }.join(', ').html_safe
    end
  end

  def pseud_link(pseud)
    if @downloading
      link_to(pseud.byline, user_pseud_path(pseud.user, pseud, :only_path => false), :rel => "author")
    else
      link_to(pseud.byline, user_pseud_path(pseud.user, pseud), :class => "login author", :rel => "author")
    end
  end
  
   # A plain text version of the byline, for when we don't want to deliver a linkified version.
  def text_byline(creation, options={})
    if creation.respond_to?(:anonymous?) && creation.anonymous?
      anon_byline = ts("Anonymous")
      if (logged_in_as_admin? || is_author_of?(creation)) && !options[:visibility] == 'public'
        anon_byline += " [".html_safe + non_anonymous_byline(creation) + "]".html_safe
        end
      return anon_byline
    end
    non_anonymous_text_byline(creation)
  end
      
  def non_anonymous_text_byline(creation)
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
            pseud_text(pseud) :
            archivists[pseud] + ts("[archived by") + pseud_text(pseud) + "]"
      }.join(', ').html_safe
    end
  end

  def pseud_text(pseud)
      pseud.byline
  end

   def link_to_modal(content="",options = {})   
     options[:class] ||= ""
     options[:for] ||= ""
     options[:title] ||= options[:for]
     
     html_options = {"class" => options[:class] +" modal", "title" => options[:title], "aria-controls" => "#modal"}     
     link_to content, options[:for], html_options
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
    
    " ".html_safe + link_to_modal(link, :for => help_file, :title => help_entry.split('-').join(' ').capitalize, :class => "help symbol question").html_safe
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
  # The CSS classes are specified in system-messages.css.
  #
  # You can also have multiple possible flash alerts in a single location with:
  #       <%= flash_div :error, :caution, :notice %>
  # (These are the three varieties currently defined.) 
  #
  def flash_div *keys
    keys.collect { |key| 
      if flash[key]
        if flash[key].is_a?(Array)
          content_tag(:div, content_tag(:ul, flash[key].map {|flash_item| content_tag(:li, h(flash_item))}.join("\n").html_safe), :class => "flash #{key}") 
        else
          content_tag(:div, h(flash[key]), :class => "flash #{key}") 
        end
      end
    }.join.html_safe
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
      link_to_unless condition, ((direction == 'ASC' ? '&#8593;&#160;' : '&#8595;&#160;') + title).html_safe, 
          request.parameters.merge( {:sort_column => column, :sort_direction => direction} ), {:class => css_class, :title => (direction == 'ASC' ? ts('sort up') : ts('sort down'))}
    else
      link_to_unless params[:sort_column].nil?, title, url_for(params.merge :sort_column => nil, :sort_direction => nil)
    end
  end

  ## Allow use of tiny_mce WYSIWYG editor
  def use_tinymce
    @content_for_tinymce = "" 
    content_for :tinymce do
      javascript_include_tag "tinymce/tinymce.min.js"
    end
    @content_for_tinymce_init = "" 
    content_for :tinymce_init do
      javascript_include_tag "mce_editor.min.js"
    end
  end  
  
  # check for pages that allow tiny_mce before loading the massive javascript
  def allow_tinymce?(controller)
    %w(admin_posts archive_faqs known_issues chapters works).include?(controller.controller_name) &&
      %w(new create edit update).include?(controller.action_name)
  end

  def params_without(name)
    params.reject{|k,v| k == name}
  end

  # see: http://www.w3.org/TR/wai-aria/states_and_properties#aria-valuenow
  def generate_countdown_html(field_id, max) 
    max = max.to_s
    span = content_tag(:span, max, :id => "#{field_id}_counter", :class => "value", "data-maxlength" => max, "aria-live" => "polite", "aria-valuemax" => max, "aria-valuenow" => field_id)
    content_tag(:p, span + ts(' characters left'), :class => "character_counter")
  end
  
  # expand/contracts all expand/contract targets inside its nearest parent with the target class (usually index or listbox etc) 
  def expand_contract_all(target="index")
    expand_all = content_tag(:a, ts("Expand All"), :href=>"#", :class => "expand_all", "target_class" => target, :role => "button")
    contract_all = content_tag(:a, ts("Contract All"), :href=>"#", :class => "contract_all", "target_class" => target, :role => "button")
    content_tag(:span, expand_all + "\n".html_safe + contract_all, :class => "actions hidden showme", :role => "menu")
  end
  
  # Sets up expand/contract/shuffle buttons for any list whose id is passed in
  # See the jquery code in application.js
  # Note that these start hidden because if javascript is not available, we
  # don't want to show the user the buttons at all.
  def expand_contract_shuffle(list_id, shuffle=true)
    ('<span class="action expand hidden" title="expand" action_target="#' + list_id + '"><a href="#" role="button">&#8595;</a></span>
    <span class="action contract hidden" title="contract" action_target="#' + list_id + '"><a href="#" role="button">&#8593;</a></span>').html_safe +
    (shuffle ? ('<span class="action shuffle hidden" title="shuffle" action_target="#' + list_id + '"><a href="#" role="button">&#8646;</a></span>') : '').html_safe
  end
  
  # returns the default autocomplete attributes, all of which can be overridden
  # note: we do this and put the message defaults here so we can use translation on them
  def autocomplete_options(method, options={})
    {      
      :class => "autocomplete",
      :autocomplete_method => (method.is_a?(Array) ? method.to_json : "/autocomplete/#{method}"),
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
    link_to_function(linktext, "add_section(this, \"#{nested_model_name}\", \"#{escape_javascript(rendered_partial_to_add)}\")", :class => "hidden showme")
  end

  # see above
  def link_to_remove_section(linktext, form, class_of_section_to_remove="removeme")
    form.hidden_field(:_destroy) + "\n" +
    link_to_function(linktext, "remove_section(this, \"#{class_of_section_to_remove}\")", :class => "hidden showme")
  end
  
  def time_in_zone(time, zone=nil, user=User.current_user)
    return ts("(no time specified)") if time.blank?
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
    "<a href=\"mailto:#{h(user.email)}?subject=[#{ArchiveConfig.APP_SHORT_NAME}]#{options[:subject]}\" class=\"mailto\">
      <img src=\"/images/envelope_icon.gif\" alt=\"email #{h(user.login)}\">
    </a>".html_safe
  end

  # these two handy methods will take a form object (eg from form_for) and an attribute (eg :title or '_destroy')
  # and generate the id or name that Rails will output for that object
  def field_attribute(attribute)
    attribute.to_s.sub(/\?$/,"")
  end

  def name_to_id(name)
    name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
  end
  
  def field_id(form, attribute)
    name_to_id(field_name(form, attribute))
  end

  def field_name(form, attribute)
    "#{form.object_name}[#{field_attribute(attribute)}]"
  end
  
  def nested_field_id(form, nested_object, attribute)
    name_to_id(nested_field_name(form, nested_object, attribute))
  end
  
  def nested_field_name(form, nested_object, attribute)
    "#{form.object_name}[#{nested_object.class.table_name}_attributes][#{nested_object.id}][#{field_attribute(attribute)}]"
  end
  
  
  # toggle an checkboxes (scrollable checkboxes) section of a form to show all of the checkboxes
  def checkbox_section_toggle(checkboxes_id, checkboxes_size, options = {})
    toggle_show = content_tag(:a, ts("Show all %{checkboxes_size} checkboxes", :checkboxes_size => checkboxes_size), 
                              :class => "toggle #{checkboxes_id}_show") + "\n".html_safe

    toggle_hide = content_tag(:a, ts("Collapse checkboxes"), :style => "display: none;",
                              :class => "toggle #{checkboxes_id}_hide", :href => "##{checkboxes_id}") +
                              "\n".html_safe
    
    css_class = checkbox_section_css_class(checkboxes_size)
 
    javascript_bits = content_for(:footer_js) {
      javascript_tag("$j(document).ready(function(){\n" +
        "$j('.#{checkboxes_id}_show').click(function() {\n" +
          "$j('##{checkboxes_id}').attr('class', 'options index all');\n" + 
          "$j('.#{checkboxes_id}_hide').show();\n" +
          "$j('.#{checkboxes_id}_show').hide();\n" +
        "});" + "\n" + 
        "$j('.#{checkboxes_id}_hide').click(function() {\n" +
          "$j('##{checkboxes_id}').attr('class', '#{css_class}');\n" +
          "$j('.#{checkboxes_id}_show').show();\n" +
          "$j('.#{checkboxes_id}_hide').hide();\n" +
        "});\n" +
      "})")
    }

    toggle = content_tag(:p, 
      (options[:no_show] ? "".html_safe : toggle_show) + 
      toggle_hide + 
      (options[:no_js] ? "".html_safe : javascript_bits), :class => "actions")
  end
  
  # FRONT END: is this and the toggle now formatted properly? (NB in the signup form this is currently displaying to the left of the inline checkboxes) I suspect this is a listbox
  #
  # create a scrollable checkboxes section for a form that can be toggled open/closed
  # form: the form this is being created in
  # attribute: the attribute being set 
  # choices: the array of options (which should be objects of some sort)
  # checked_method: a method that can be run on the object of the form to get back a list 
  #         of currently-set options
  # name_method: a method that can be run on each individual option to get its pretty name for labelling (typically just "name")
  # value_method: a value that can be run to get the value of each individual option
  # 
  #
  # See the prompt_form in challenge signups for example of usage
  def checkbox_section(form, attribute, choices, options = {})
    options = {
      :checked_method => nil, 
      :name_method => "name", 
      :name_helper_method => nil, # alternative: pass a helper method that gets passed the choice
      :extra_info_method => nil, # helper method that gets passed the choice, for any extra information that gets attached to the label
      :value_method => "id", 
      :disabled => false,
      :include_toggle => true,
      :checkbox_side => "left",
      :include_blank => true,
      :concise => false # specify concise to invoke alternate formatting for skimmable lists (two-column in default layout)
    }.merge(options)
    
    field_name = options[:field_name] || field_name(form, attribute)
    field_name += '[]'
    base_id = options[:field_id] || field_id(form, attribute)
    checkboxes_id = "#{base_id}_checkboxes"
    opts = options[:disabled] ? {:disabled => "true"} : {}
    already_checked = case 
      when options[:checked_method].is_a?(Array)
        options[:checked_method]
      when options[:checked_method].nil?
        []
      else
        form.object.send(options[:checked_method]) || []
      end
    
    checkboxes = choices.map do |choice|      
      is_checked = !options[:checked_method] || already_checked.empty? ? false : already_checked.include?(choice)
      display_name = case
        when options[:name_helper_method]
          eval("#{options[:name_helper_method]}(choice)")
        else
          choice.send(options[:name_method]).html_safe
        end
      value = choice.send(options[:value_method])
      checkbox_id = "#{base_id}_#{name_to_id(value)}"
      checkbox = check_box_tag(field_name, value, is_checked, opts.merge({:id => checkbox_id}))
      checkbox_and_label = label_tag checkbox_id, :class => "action" do 
        options[:checkbox_side] == "left" ? checkbox + display_name : display_name + checkbox
      end
      if options[:extra_info_method]
        checkbox_and_label = options[:checkbox_side] == "left" ? checkbox_and_label + eval("#{options[:extra_info_method]}(choice)") : eval("#{options[:extra_info_method]}(choice)") + checkbox_and_label
      end
      content_tag(:li, checkbox_and_label, :class => cycle("odd", "even", :name => "tigerstriping"))
    end.join("\n").html_safe
    checkboxes_ul = content_tag(:ul, checkboxes)

    # reset the tiger striping
    reset_cycle("tigerstriping")

    # if there are only a few choices, don't show the scrolling and the toggle
    size = choices.size
    css_class = checkbox_section_css_class(size, options[:concise])
    top_toggle = "".html_safe
    bottom_toggle = "".html_safe
    if options[:include_toggle] && !options[:concise] && size > (ArchiveConfig.OPTIONS_TO_SHOW * 6)
      top_toggle = checkbox_section_toggle(checkboxes_id, size)
      bottom_toggle = checkbox_section_toggle(checkboxes_id, size, :no_show => true, :no_js => true)
    end
      
    # We wrap the whole thing in a div module with the classes
    return content_tag(:div, top_toggle + checkboxes_ul + bottom_toggle + (options[:include_blank] ? hidden_field_tag(field_name, " ") : ''.html_safe), :id => checkboxes_id, :class => css_class)
  end
  
  def checkbox_section_css_class(size, concise=false)
    css_class = "options index"
    
    if concise
      css_class += " concise lots" if size > ArchiveConfig.OPTIONS_TO_SHOW
    else
      css_class += " many" if size > ArchiveConfig.OPTIONS_TO_SHOW
      css_class += " lots" if size > (ArchiveConfig.OPTIONS_TO_SHOW * 6)
    end
    
    css_class
  end
  
  def check_all_none(all_text="All", none_text="None", name_filter=nil)
    filter_attrib = (name_filter ? " checkbox_name_filter=\"#{name_filter}\"" : '')    
    ('<ul class="actions">
      <li><a href="#" class="check_all"' + 
      "#{filter_attrib}>#{all_text}</a></li>" +
      '<li><a href="#" class="check_none"' + 
      "#{filter_attrib}>#{none_text}</a></li></ul>").html_safe
  end
  
  def submit_button(form=nil, button_text=nil)
    button_text ||= (form.nil? || form.object.nil? || form.object.new_record?) ? ts("Submit") : ts("Update")
    content_tag(:p, (form.nil? ? submit_tag(button_text) : form.submit(button_text)), :class=>"submit")
  end
    
  def submit_fieldset(form=nil, button_text=nil)
    content_tag(:fieldset, content_tag(:legend, ts("Actions")) + submit_button(form, button_text))
  end
  
  # Cache fragments of a view if +condition+ is true
  #
  # <%= cache_if admin?, project do %>
  # <b>All the topics on this project</b>
  # <%= render project.topics %>
  # <% end %>
  def cache_if(condition, name = {}, options = nil, &block)
    if condition
      cache(name, options, &block)
    else
      yield
    end
    nil
  end
    
end # end of ApplicationHelper
