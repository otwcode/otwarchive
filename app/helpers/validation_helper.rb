module ValidationHelper

  # use to make sure we have consistent name throughout
  def live_validation_varname(id)
    "validation_for_#{id}"
  end

  # puts the standard wrapper around the code and declares the LiveValidation object
  def live_validation_wrapper(id, validation_code)
    valid = "<script>\n"
    valid += "var #{live_validation_varname(id)} = new LiveValidation('#{id}', { wait: 500 });\n"
    valid += validation_code
    valid += "</script>\n"
    return valid
  end

  # Generate javascript call for live validation. All the messages have default translated values. 
  # Options:
  # :presence => true/false -- ensure the field is not blank. (default TRUE)
  # :failureMessage => msg -- shown if field is blank (default "Must be present.")
  # :validMessage => msg -- shown when field is ok (default empty)
  # :maximum_length => [max value] -- field must be no more than this many characters long 
  # :tooLongMessage => msg -- shown if too long
  # :minimum_length => [min value] -- field must be at least this many characters long 
  # :tooShortMessage => msg -- shown if too short
  #
  # Most basic usage: 
  #   <input type=text id="field_to_validate">
  #   <%= live_validation_for_field("field_to_validate") -%>
  # This will make sure this field is present and use translated error messages. 
  # 
  # More custom usage (from work form): 
  #    <%= c.text_area :content, :class => "mce-editor", :id => "content" %>
  #    <%= live_validation_for_field('content', 
  #        :maximum_length => ArchiveConfig.CONTENT_MAX, :minimum_length => ArchiveConfig.CONTENT_MIN, 
  #        :tooLongMessage => 'We salute your ambition! But sadly the content must be less than %d letters long. (Maybe you want to create a multi-chaptered work?)'/ArchiveConfig.CONTENT_MAX,
  #        :tooShortMessage => 'Brevity is the soul of wit, but your content does have to be at least %d letters long.'/ArchiveConfig.CONTENT_MIN,
  #        :failureMessage => 'You did want to post a story here, right?'.t)
  #    -%>
  # 
  # Add more default values here! There are many more live validation options, see the code in
  # the javascripts folder for details. 
  def live_validation_for_field(id, options = {})
    defaults = {:presence => true,
                :failureMessage => 'Must be present.'.t,
                :validMessage => ''}                
    if options[:maximum_length]
      defaults.merge!(:tooLongMessage => 'Must be less than %d letters long.'/options[:maximum_length]) #/
    end
    if options[:minimum_length]
      defaults.merge!(:tooShortMessage => 'Must be at least %d letters long.'/options[:minimum_length]) #/
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
    
    return live_validation_wrapper(id, validation_code)
  end

end