# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
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
    keys.collect { |key| content_tag(:div, flash[key],
                                     :class => "flash #{key}") if flash[key] }.join
  end

    # Create a nicer language menu than the Click-To-Globalize default
  def languages_menu
    result = "<form action=" + url_for(:action => 'set', :controller => 'locale') + ">\n" 
    result << "<select name='id' onchange='this.form.submit()'>\n"
    # We'll sort the languages by their keyname rather than 
    languages.sort {|a, b| a.first.to_s <=> b.first.to_s }.each do |language, locale|
      # get the native name of the language
      langname = (langobj = Language.pick(locale)).nil? ? language.to_s : langobj.native_name
      langname = langname.titleize;
      
      if locale == Locale.active.code
        result << "<option value=#{locale} selected><strong>#{langname}</strong></option>\n"
      else
        result << "<option value=#{locale}>#{langname}</option>\n"
      end
    end
    result << "</select>"
    result << "<noscript><input type=submit name=commit value='Go'></noscript>"
    result << "</form>"
    return result
    
    #    result = ''
    #    translated_languages.each do |langname, locale|
    #      result << "<li>#{link_to langname.titleize, {:controller => 'locale', :action => 'set', :id => locale}, {:title => "#{langname} [#{locale}]"}}</li>"
    #      result << "\n"
    #    end
    #    return result
  end  
  
  
end
