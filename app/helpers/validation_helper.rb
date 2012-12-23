module ValidationHelper

  # Set a custom error-message handler that puts the errors on 
  # their respective fields instead of on the top of the page
  ActionView::Base.field_error_proc = Proc.new {|html_tag, instance|
    %(<span class='error'>#{html_tag}</span>).html_safe
    # # don't put errors on the labels, duh
    # if !html_tag.match(/label/)
    #   %(<span class='error'>#{html_tag}</span>).html_safe
    # elsif instance.error_message.kind_of?(Array)
    #   %(<span class='error'>#{html_tag} <ul class='error'><li>#{instance.error_message.join('</li><li>')}</li></ul></span>).html_safe
    # else
    #   %(<span class='error'>#{html_tag} #{instance.error_message}</span>).html_safe
    # end
  }
  
  # much simplified and html-safed version of error_messages_for
  # error messages containing a "^" will have everything before the "^" wiped out
  def error_messages_for(object)
    if object.is_a? Symbol
      object = instance_variable_get("@#{object}")
    end
    
    if object && object.errors.any?
      errors = object.errors.full_messages
      intro = content_tag(:h4, h(ts("Sorry! We couldn't save this %{objectname} because:", :objectname => object.class.model_name.human.to_s.downcase.gsub(/_/, ' '))))
      error_messages_formatted(errors, intro)
    end
  end
  
  def error_messages_formatted(errors, intro = "")
    return unless errors && !errors.empty?
    error_messages = errors.map {|msg| content_tag(:li, msg.gsub(/^(.+)\^/, '').html_safe)}.join("\n").html_safe
    content_tag(:div, intro.html_safe + content_tag(:ul, error_messages), :id =>"error", :class=>"error")    
  end
  
  # use to make sure we have consistent name throughout
  def live_validation_varname(id)
    "validation_for_#{id}"
  end

  # puts the standard wrapper around the code and declares the LiveValidation object
  def live_validation_wrapper(id, validation_code)
    valid = "var #{live_validation_varname(id)} = new LiveValidation('#{id}', { wait: 500, onlyOnBlur: false });\n".html_safe
    valid += validation_code
    return javascript_tag valid
  end

  # Generate javascript call for live validation. All the messages have default translated values. 
  # Options:
  # :presence => true/false -- ensure the field is not blank. (default TRUE)
  # :failureMessage => msg -- shown if field is blank (default "Must be present.")
  # :validMessage => msg -- shown when field is ok (default has been set to empty in the actual livevalidation.js file)
  # :maximum_length => [max value] -- field must be no more than this many characters long 
  # :tooLongMessage => msg -- shown if too long
  # :minimum_length => [min value] -- field must be at least this many characters long 
  # :tooShortMessage => msg -- shown if too short
  #
  # Most basic usage: 
  #   <input type=text id="field_to_validate">
  #   <%= live_validation_for_field("field_to_validate") %>
  # This will make sure this field is present and use translated error messages. 
  # 
  # More custom usage (from work form): 
  #    <%= c.text_area :content, :class => "mce-editor", :id => "content" %>
  #    <%= live_validation_for_field('content', 
  #        :maximum_length => ArchiveConfig.CONTENT_MAX, :minimum_length => ArchiveConfig.CONTENT_MIN, 
  #        :tooLongMessage => 'We salute your ambition! But sadly the content must be less than %d letters long. (Maybe you want to create a multi-chaptered work?)'/ArchiveConfig.CONTENT_MAX,
  #        :tooShortMessage => 'Brevity is the soul of wit, but your content does have to be at least %d letters long.'/ArchiveConfig.CONTENT_MIN,
  #        :failureMessage => 'You did want to post a story here, right?')
  #    %>
  # 
  # Add more default values here! There are many more live validation options, see the code in
  # the javascripts folder for details. 
  def live_validation_for_field(id, options = {})
    defaults = {:presence => true,
                :failureMessage => 'Must be present.',
                :validMessage => ''}                
    if options[:maximum_length]
      defaults.merge!(:tooLongMessage => 'Must be less than ' + options[:maximum_length].to_s + ' letters long.') #/
    end
    if options[:minimum_length]
      defaults.merge!(:tooShortMessage => 'Must be at least ' + options[:minimum_length].to_s + ' letters long.') #/
    end
    if options[:notANumberMessage]
      defaults.merge!(:notANumberMessage => 'Please enter a number') #/
    end

    options = defaults.merge(options)
    
    validation_code = ""
    if options[:presence]
      validation_code += "#{live_validation_varname(id)}.add(Validate.Presence, {\"failureMessage\":\"#{options[:failureMessage]}\", \n"
      validation_code += "\"validMessage\":\"#{options[:validMessage]}\"});\n"
    end
    
    if options[:maximum_length]
      validation_code += "#{live_validation_varname(id)}.add(Validate.Length, { \"maximum\":\"#{options[:maximum_length]}\", \n" 
      validation_code += "\"tooLongMessage\": \"#{options[:tooLongMessage]}\"}); \n"     
    end
    
    if options[:minimum_length]
      validation_code += "#{live_validation_varname(id)}.add(Validate.Length, { \"minimum\":\"#{options[:minimum_length]}\", \n" 
      validation_code += "\"tooShortMessage\": \"#{options[:tooShortMessage]}\"}); \n"           
    end
    
    if options[:numericality]
      validation_code += "#{live_validation_varname(id)}.add(Validate.Numericality, { \"notANumberMessage\":\"#{options[:notANumberMessage]}\", \n"
      validation_code += "\"validMessage\":\"#{options[:validMessage]}\"});\n"
    end
    
    if options[:exclusion]
      exclusion_string = "['"
      exclusion_string += options[:exclusion].join("', '")
      exclusion_string += "']"
      validation_code += "#{live_validation_varname(id)}.add(Validate.Exclusion, { \n"
      validation_code += "\"within\": #{exclusion_string}, \n"
      validation_code += "\"failureMessage\":\"#{options[:failureMessage]}\", \n"
      validation_code += "\"validMessage\":\"#{options[:validMessage]}\"});\n"
    end
    
    return live_validation_wrapper(id, validation_code.html_safe)
  end

end
