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
    result = "<form action=" + url_for(:action => 'set', :controller => 'locale') + ">\n" 
    result << "<select name='id' onchange='this.form.submit()'>\n"
    # We'll sort the languages by their keyname rather than have all the non-arabic-character-set
    # ones end up at the end of the list.
    LANGUAGE_NAMES.sort {|a, b| a.first.to_s <=> b.first.to_s }.each do |locale, langname|
      langname = langname.titleize;   
      puts "#{locale}, #{langname}, #{Locale.active.language.code}\n\n"
      if locale == Locale.active.language.code
        result << "<option value=#{locale} selected><strong>#{langname}</strong></option>\n"
      else
        result << "<option value=#{locale}>#{langname}</option>\n"
      end
    end
    result << "</select>"
    result << "<noscript><input type=submit name=commit value='Go'></noscript>"
    result << "</form>"
    return result
  end  

  # Get the translating button
  def translating_button
    if @current_user.translation_mode_active?
      image_tag("translation_button_down.gif", :alt => "Stop translating", :border => 0)
    else
      image_tag("translation_button_up.gif", :alt => "Start translating", :border => 0)
    end
  end
  
  
end
