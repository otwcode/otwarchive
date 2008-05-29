# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper 
  
  # Can be used to check ownership of any item that has a pseud attached to it
  def is_author_of?(item) 
    return false unless logged_in?
    if item.class == Work || item.class == Chapter
      item.pseuds & current_user.pseuds != []
    else
      current_user.pseuds.include?(item.pseud)
    end
  end

  def byline(creation)
    pseuds = creation.authors ? creation.authors : creation.pseuds 
    pseuds.collect { |pseud|
      link_to pseud.name, user_path(pseud.user), :class => "login story-author"
    }.join(', ')
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
        content_tag(:div, 
                    image_tag("icon-#{key}.gif", :class => "flash_icon") + "\n" + flash[key], 
        :class => "flash #{key}") if flash[key] 
      end
    }.join
  end
  
  # Create a nicer language menu than the Click-To-Globalize default
  def languages_menu
    result = "<form action=\"" + url_for(:action => 'set', :controller => 'locale') + "\">\n" 
    result << "<select name='url' onchange='this.form.submit()'>\n"
    # We'll sort the languages by their keyname rather than have all the non-arabic-character-set
    # ones end up at the end of the list.
    LANGUAGE_NAMES.sort {|a, b| a.first.to_s <=> b.first.to_s }.each do |locale, langname|
      langname = langname.titleize;   
      if Locale.active && Locale.active.language && locale == Locale.active.language.code
        result << "<option value=\"#{url_for :overwrite_params => {:locale => locale}}\" selected><strong>#{langname} (#{locale})</strong></option>\n"
      else
        result << "<option value=\"#{url_for :overwrite_params => {:locale => locale}}\">#{langname} (#{locale})</option>\n"
      end
    end
    result << "</select>"
    result << "<noscript><input type=submit name=commit value='Go'></noscript>"
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

    
  # Validation messages
  def valid_length_message
    "Thanks, that length looks good.".t
  end

  #santizes and formats a string with paragraphs
  def sanitize_format(content)
    close_tags(sanitize(simple_format(content)))
  end
    
  #closes tags in html (uses http://snippets.dzone.com/posts/show/3822, but
  #modified)
  def close_tags(html)
    # no closing tag necessary for these
    soloTags = ["br","hr"]
    # Analyze all <> elements
    stack = Array.new
    result = html.gsub( /(<.*?>)/m ) do | element |
      if element =~ /\A<\/(\w+)/ then
        # </tag>
        tag = $1.downcase
        if stack.include?(tag) then
          # If allowed and on the stack
          # Then pop down the stack
          top = stack.pop
          out = "</#{top}>"
          until top == tag do
            top = stack.pop
            out << "</#{top}>"
          end
          out
        end
      elsif element =~ /\A<(\w+)\s*\/>/
        # <tag />
        tag = $1.downcase
        "<#{tag} />"
      elsif element =~ /\A<(\w+)/ then
        # <tag ...>
        tag = $1.downcase
        if ! soloTags.include?(tag) then
            stack.push(tag)
        end
        out = "<#{tag}"
        tag = $1.downcase
        while ( $' =~ /(\w+)=("[^"]+")/ )
           attr = $1.downcase
           valu = $2
           out << " #{attr}=#{valu}"
        end
        out << ">"
      end
    end

    # eat up unmatched leading >
    while result.sub!(/\A([^<]*)>/m) { $1 } do end

    # eat up unmatched trailing <
    while result.sub!(/<([^>]*)\Z/m) { $1 } do end

    # clean up the stack
    if stack.length > 0 then
      result << "</#{stack.reverse.join('></')}>"
    end

    result
  end
  
  def translation_button
    if current_user.has_role? 'translator'
      return '<li> <a href="' + url_for(:controller => 'translation', :action => 'index') + '"' +
      image_tag("translation_button.gif", :alt => h('Link to translation page'.t), :border => 0) + "</a></li>"
    end
  end

end
