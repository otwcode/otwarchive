module FormTestHelper
  module TagProxy
    def method_missing(method, *args)
      if tag.respond_to?(method)
        tag.send(method, *args)
      else
        super
      end
    end
  end
  
  class Form
    class FieldNotFoundError < RuntimeError; end
    class MissingSubmitError < RuntimeError; end
    include TagProxy
    attr_reader :tag
    
    REMOTE_FORM_ONSUBMIT_ACTION_RGX = /new Ajax.Request\('([^']+)'/
    
    def initialize(tag, testcase, options={})
      @tag, @testcase = tag, testcase, 
      @submit_value = options.delete(:submit_value)
      @xhr = options.delete(:xhr)
    end

    def xhr?
      @xhr
    end

    # If you submit the form with JavaScript
    def submit_without_clicking_button
      if xhr?
        if tag.attributes['onsubmit'] =~ REMOTE_FORM_ONSUBMIT_ACTION_RGX
          path = $1
        else
          raise "No path found for the remote request"
        end
      else
        path = self.action.blank? ? self.uri : self.action # If no action attribute on form, it submits to the same URI where the form was displayed
      end
      params = {}
      fields.each {|field| params[field.name] = field.value unless field.value.nil? || field.value == [] || params[field.name] } # don't submit the nils, empty arrays, and fields already named
      
      # Convert arrays and hashes in param keys, since test processing doesn't do this automatically
      params = ActionController::UrlEncodedPairParser.new(params).result
      @testcase.make_request(request_method, path, params, self.uri, @xhr)
    end
    
    # Submits the form.  Raises an exception if no submit button is present.
    def submit(opts={})
      msg = "Submit button not found in form"
      selector = 'input[type="submit"], input[type="image"], button[type="submit"]'
      if @submit_value
        msg << " with a value of '#{@submit_value}'"
        selector.gsub!(/\]/, "][value=#{@submit_value}]")
      end
      raise MissingSubmitError, msg unless tag.select(selector).any?
      fields_hash.update(opts)
      submit_without_clicking_button
    end
    
    def uri
      @testcase.instance_variable_get("@request").request_uri
    end
    
    def field_names
      fields.collect {|field| field.name }
    end
    
    def fields
      return @fields if @fields
      # Input, textarea, select, and button are valid field tags.  Name is a required attribute.
      fields = tag.select('input, textarea, select, button').reject{ |tag| tag['name'].nil? }
      @fields = fields.group_by {|field_tag| field_tag['name'] }.collect do |name, field_tags|
        case field_tags.first['type']
        when 'submit'
          field_tags.reject!{ |tag,*| tag['value'] != @submit_value } if @submit_value
          FormTestHelper::Submit.new(field_tags)
        when 'checkbox'
          FormTestHelper::CheckBox.new(field_tags)
        when 'hidden'
          FormTestHelper::Hidden.new(field_tags)
        when 'radio'
          FormTestHelper::RadioButtonGroup.new(field_tags)
        else
          if field_tags.first.name == 'select'
            if  field_tags.first['multiple'] # The multiple attribute is set
              FormTestHelper::SelectMultiple.new(field_tags)
            else
              FormTestHelper::Select.new(field_tags)
            end
          else
            FormTestHelper::Field.new(field_tags)
          end
        end
      end
    end
    
    def fields_hash
      @fields_hash ||= FieldsHash.new(ActionController::UrlEncodedPairParser.new(fields.collect {|field| [field.name, field] }).result)
    end
    
    # Accepts a block that can work with a single object (group of fields corresponding to a 
    # single ActiveRecord object)
    #
    # Example:
    #   form.with_object(:book) do |book|
    #     book.name = 'Pickaxe'
    #     book.category = 'Programming'
    #     book.classic.check
    #   end
    def with_object(object_name)
      yield self.send(object_name)
    end
    
    def find_field_by_name(field_name)
      field_name = field_name.to_s.gsub(/\[\]$/, '') # Strip any trailing empty square brackets
      matching_fields = self.fields.select {|field| field.name == field_name }
      return nil if matching_fields.empty?
      matching_fields.first
    end
    
    # Same as find_field_by_name but raises an exception if the field doesn't exist.
    def [](field_name)
      find_field_by_name(field_name) || raise(FieldNotFoundError, "Field named '#{field_name}' not found in form.")
    end
    
    def method_missing(method, *args)
      method = method.to_s
      if method.gsub!(/=$/, '')
        self[method].value = *args
      elsif fields_hash.has_key?(method)
        fields_hash[method].proxy
      else
        self[method].proxy
      end
    end
    
    def []=(field_name, value)
      self[field_name].value = value
    end
    
    def reset
      fields.each {|field| field.reset }
    end
    
    def action
      tag["action"]
    end
    
    def request_method
      hidden_method_field = self.find_field_by_name("_method")
      if hidden_method_field # PUT and DELETE
        hidden_method_field.value.to_sym
      elsif tag["method"] && !tag["method"].blank? # POST and GET
        tag["method"].to_sym
      else # No method specified in form tags
        :get
      end
    end
  end
  
  # A hash of fields to allow infinite nesting of fields named like 'person[address][street]'
  class FieldsHash < HashWithIndifferentAccess
    class FieldNotFoundError < RuntimeError; end
    
    # Uses #merge! instead of #update when creating a new FieldsHash so #update can update
    # field values, not the field objects themselves.
    def initialize(constructor = {})
      if constructor.is_a?(Hash)
        # super()
        merge!(constructor)
      else
        super(constructor)
      end
    end
    
    # Ignore requests for a proxy
    def proxy; self end
    
    # Allow field values to be merged in from a hash.
    # Example:
    #   new_book = {
    #     :name => 'Pickaxe',
    #     :category => 'Programming',
    #     :classic => true,
    #   }
    #   form.book.update(new_book)
    def update(other_hash)
      other_hash.each_pair { |key, value| self[key].update(value) }
      self
    end
    
    def [](key)
      unless self.has_key?(key)
        raise(FieldNotFoundError, "Field named '#{key.to_s}' not found in FieldsHash.") 
      end
      super
    end
    
    # Allows setting form field values using key access to form fields:
    # Examples:
    #   form = select_form
    #   form.user['name'] = 'joe'
    #
    #   submit_form do |form|
    #     form.user['name'] = 'joe'
    #   end
    # 
    def []=(key, value)
      self[key].value = value
    end

    
    protected
    
    def convert_value(value)
      value.is_a?(Hash) ? FieldsHash.new(value) : value
    end
    
    def method_missing(method, *args)
      method = method.to_s
      if method.gsub!(/=$/, '') && self.has_key?(method)
        self[method].value = *args
      else
        self[method].proxy
      end
    end
  end
  
  # Gets mixed into field values (strings, arrays) to make them respond to field methods
  module FieldProxy
    attr_accessor :field
    
    def method_missing(*args)
      @field.send(*args)
    end
  end
  
  class Field
    include TagProxy
    attr_accessor :value
    attr_reader :name, :tags
    
    def initialize(tags)
      @tags = tags
      reset
    end
        
    def tag
      tags.first
    end
    
    def initial_value
      if tag['value']
        tag['value']
      elsif tag.children
        tag.children.to_s
      end
    end
    
    # The name for the field (which may have multiple values)
    # Multiple form elements with the same name are considered only one field.  Fields that return
    # multiple values when submitted are indicated with square brackets at the end of their
    # name in HTML, but have no such ending internal to this class.
    def name
      tag['name'].gsub(/\[\]$/, '')
    end
    
    def reset
      @value = initial_value
    end

    def to_s
      self.value.to_s
    end
    
    def proxy
      returning @value do |value| 
        value.extend(FieldProxy)
        value.field = self
      end
    end
    
    # Update the value of the field.
    # This enables updates to be done recursively through FieldsHashes until a form is reached
    def update(new_value)
      self.value = new_value
    end
  end
  
  class Submit < Field; end
  
  class CheckBox < Field
    def initial_value
      tag['checked'] ? checked_value : unchecked_value
    end
    
    def checked_value
      @checkbox_tag = tags.detect {|field_tag| field_tag['type'] == 'checkbox' }
      @checkbox_tag['value']
    end
    
    def unchecked_value
      @hidden_tag = tags.detect {|field_tag| field_tag['type'] == 'hidden' }
      @hidden_tag ? @hidden_tag['value'] : nil
    end
    
    def value=(value)
      case value
      when TrueClass, FalseClass
        @value = value ? checked_value : unchecked_value
      when checked_value, unchecked_value
        super
      else
        raise "Checkbox value must be one of #{[checked_value, unchecked_value].inspect}."
      end
    end
    
    def check
      self.value = checked_value
    end
    
    def uncheck
      self.value = unchecked_value
    end
  end
  
  class RadioButtonGroup < Field
    def initial_value
      checked_tags = tags.select {|tag| tag['checked'] }
      # If multiple radio buttons are checked, Firefox uses the last one
      # If none, the value is undefined and is not submitted
      checked_tags.any? ? checked_tags.last['value'] : nil
    end
    
    def options
      tags.collect {|tag| tag['value'] }
    end
    
    def value=(value)
      if options.include?(value)
        @value = value
      else
        raise "Can't set value '#{value}' for #{self.name} that isn't one of the radio buttons."
      end
    end
  end
  
  class Select < Field
    def initialize(tags)
      @options = tags.first.select("option").collect {|option_tag| Option.new(self, option_tag) }
      super
    end
    
    def initial_value
      selected_options = @options.select(&:initially_selected)
      case selected_options.size
      when 1
        selected_options.first.value
      when 0 # If no option is selected, browsers generally use the first
        @options.first.value
      else
        # When multiple options selected but the multiple attribute is not specified, 
        # Firefox selects the last of the options.
        selected_options.last.value
      end
    end
    
    def options
      if options_are_labeled?
        @options.collect do |option|
          [option.label, option.value]
        end
      else
        @options.collect(&:value)
      end
    end
    
    # True if options are like <option value="4">Spain</option> rather than
    # <option>Spain</option> or <option value="Spain">Spain</option>
    def options_are_labeled?
      @options.any? {|option| option.label }
    end
    
    # If +value+ is a label, return the real value.  If not an option, raise error.
    def lookup_in_options(value)
      if options.include?(value)
        return value
      elsif options_are_labeled? && pair = options.detect {|option| option.include?(value.to_s) }
        return pair.last
      else
        raise "Value '#{value}' isn't one of the options for #{self.name}."
      end
    end
    
    def value=(value)
      @value = lookup_in_options(value)
    end
  end
  
  # A select element that allows multiple values to be set
  class SelectMultiple < Select
    class NameMissingSquareBracketsError < RuntimeError; end
    
    def initialize(tags)
      super
      raise NameMissingSquareBracketsError, "The name of #{name} must be #{name}[] for multiple values to be sent to Rails' params" unless tag['name'] =~ /\[\]$/
    end
    
    def initial_value
      @options.select(&:initially_selected).collect(&:value)
    end
    
    def value=(values)
      @value = values.collect {|value| lookup_in_options(value) }
    end
  end
  
  class Option
    attr_reader :tag, :label, :value, :initially_selected
    def initialize(select, tag)
      @select, @tag = select, tag
      @initially_selected = tag['selected']
      content = tag.children.to_s
      value = tag['value']
      if value && value != content # Like <option value="7">United States</option>
        @label = content
        @value = value
      else # Label is nil if like <option>United States</option> or value == content
        @value = content
      end
    end
  end
  
  class Hidden < Field
    def value=(value)
      raise TypeError, "Can't modify hidden field's value"
    end
    
    # Permit changing the value of a hidden field (as if using Javascript)
    def set_value(value)
      @value = value
    end
  end
  
  module Link
    def follow
      path = self.href
      @testcase.make_request(request_method, path)
    end
    alias_method :click, :follow
    
    def href
      self["href"]
    end
    
    def request_method
      if self["onclick"] && self["onclick"] =~ /'_method'.*'value', '(\w+)'/
        $1.to_sym
      else
        :get
      end
    end
    
    def testcase=(testcase)
      @testcase = testcase
      self
    end
  end

end
