module Streamlined::Components
  # Create a html select component with args corresponding to the Rails
  # select method, plus the ActionView::Base instance
  #
  # Example:
  #
  #  html_fragment = Streamlined::Components::Select.render do |s|
  #    s.view = view
  #    s.object = model_underscore
  #    s.method = name
  #    s.choices = choices
  #    s.options = {:selected => selected_choices }
  #    s.html_options = {:size => 5, :multiple => true}
  #  end
  class Select
    REQUIRED_ATTRS = [:view, :object, :method, :choices]
    OPTIONAL_ATTRS = [:options, :html_options]
    attr_accessor *(REQUIRED_ATTRS + OPTIONAL_ATTRS)
    include HashInit

    def initialize(*args, &blk)
      super(*args, &blk)
      @options ||= {}
      @html_options ||= {}
      REQUIRED_ATTRS.each do |x| 
        raise(ArgumentError, "#{x} required") unless self.send(x)
      end
    end
    
    def self.render(*args, &blk)
      self.new(*args, &blk).render
    end   
    
    def self.purge_streamlined_select_none_from_params(params) 
      return params if params.blank?
      params.each do |k,v|
        params[k].delete(STREAMLINED_SELECT_NONE) if Array === params[k] 
        purge_streamlined_select_none_from_params(params[k]) if Hash === params[k]
      end
    end
    
    def render
      normal_select = view.select(object, method, choices, options, html_options)
      name = "#{object}[#{method}][]"
      hidden_none_select = view.hidden_field_tag(name, STREAMLINED_SELECT_NONE)
      normal_select + hidden_none_select
    end
    
  end
end

