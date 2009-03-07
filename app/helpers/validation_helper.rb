module ValidationHelper

  # Set a custom error-message handler that puts the errors on 
  # their respective fields instead of on the top of the page
  ActionView::Base.field_error_proc = Proc.new {|html_tag, instance|
    # don't put errors on the labels, duh
    if !html_tag.match(/label/)
      %(<span class='error'>#{html_tag}</span>)
    elsif instance.error_message.kind_of?(Array)
      %(<span class='error'>#{html_tag} <ul class='error'><li>#{instance.error_message.join('</li><li>')}</li></ul></span>)
    else
      %(<span class='error'>#{html_tag} #{instance.error_message}</span>)
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
          html[key] = 'error'
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

  # use to make sure we have consistent name throughout
  def live_validation_varname(id)
    "validation_for_#{id}"
  end

  # puts the standard wrapper around the code and declares the LiveValidation object
  def live_validation_wrapper(id, validation_code)
    valid = "<script type=\"text/javascript\">\n"
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
