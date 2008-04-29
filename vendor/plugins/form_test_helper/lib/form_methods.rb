module FormTestHelper

  module FormMethods
    # Returns a form object with the passed in +args+, which
    # can be a text selector, options and/or a possible block. All
    # of which are optional.
    #
    # When given a block the form object will be passed into the
    # the block which can be used to set values on the form. The
    # block will NOT submit the form. To submit the form you must
    # call submit on ther returned form.
    #
    # === Options
    #  * xhr - can be true or false. This sets the type of request to be
    #          made when the form is submitted. default is false
    #  * :submit_value - a string. When selecting a form with multiple submit
    #          buttons this can be used to specify the value of which submit
    #          button to use.
    #
    # === Examples
    #   # select the first form
    #   form = select_form
    #
    #   # select the form with the id 'form_id'
    #   form = select_form "form_id"
    #
    #   # select form#form_id and tell it that it will make an xhr call
    #   form = select_form "form_id", :xhr => true
    #
    #   # select form#form_id and 
    #   form = select_form "form_id", :submit_value => "yes"
    #
    #   # select the first form and tell it that it will make an xhr call
    #   form = select_form :xhr => true
    #
    #   # accesing elements whose HTML names were in a basic format like "name"
    #   form.name = "joe"
    #   form.name  # => "joe"
    #
    #   # accessing elements whose HTML names were in a format like "user[name]" 
    #   form.user.name = "joe"
    #   form.user.name  # => "joe"
    #
    def select_form(*args)
      options = args.extract_options!
      text = args.first
      xhr = options.delete(:xhr)
      submit_value = options.delete(:submit_value)
      @html_document = nil # So it always grabs the latest response
    
      forms = if text.nil?
        select_first_form
      elsif submit_value.nil?
        select_form_with_id_or_action text
      else
        select_form_with_id_or_action_and_a_submit_value(text, submit_value)
      end
    
      returning Form.new(forms.first, self, :submit_value => submit_value, :xhr => xhr ) do |form|
        if block_given?
          yield form
        end
      end
    end

    # Alias for select_form when called with a block. 
    # Shortcut for select_form(name).submit(args) without block.
    #
    # === Example
    #   # selecting a form, setting a value for a field and submitting it
    #   submit_form "form_id" do |form|
    #     form.user.name = "joe"
    #   end
    def submit_form(*args, &block)
      if block_given?
        select_form(*args, &block).submit
      else
        options = args.extract_options!
        selector = args.empty? ? nil : args
        
        submit_value = options.delete(:submit_value)
        xhr = options.delete(:xhr)
        
        select_form(selector, :xhr => xhr, :submit_value => submit_value).submit(options)
      end
    end
  
    private
  
    def find_parent(element, text)
      element.name == text ? [element] : find_parent(element.parent, text)
    end
  
    def select_first_form
      assert_select("form", 1)
    end
  
    def select_form_with_id_or_action(text)
      elements = css_select(%|form[action=#{text}]|)
      elements.any? ? elements : assert_select("form#?", text)
    end
  
    def select_form_with_id_or_action_and_a_submit_value(text, submit_value)
      elements = css_select(%|form##{text} input[type=submit][value=#{submit_value}]|) 
      elements = css_select(%|form[action=#{text}] input[type=submit][value=#{submit_value}]|) if elements.empty?
      elements.any? ? find_parent(elements.first, "form") : assert_select("form#?", text)
    end

  end 
  
end
