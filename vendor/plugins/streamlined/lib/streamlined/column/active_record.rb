class Streamlined::Column::ActiveRecord < Streamlined::Column::Base
  attr_accessor :ar_column, :enumeration, :check_box, :default_edit_value
  attr_with_default :filterable, 'true'
  delegates :name, :to => :ar_column
  delegates :table_name, :to => :parent_model
  
  def initialize(ar_column, parent_model)
    @ar_column = ar_column
    @human_name = ar_column.human_name if ar_column.respond_to?(:human_name)
    @parent_model = parent_model
  end
  
  def active_record?
    true
  end
  
  def filterable?
    filterable
  end
  
  def filter_column
    name
  end
  
  def ==(o)
    return true if o.object_id == object_id
    return false unless self.class == o.class
    return self.ar_column == o.ar_column &&
           self.human_name == o.human_name &&
           self.enumeration == o.enumeration
  end
  
  def edit_view
    Streamlined::View::EditViews.create_relationship(:enumerable_select)
  end
  
  def show_view
    Streamlined::View::ShowViews.create_summary(:enumeration)
  end
  
  def render_td_show(view, item)
    if enumeration
      content = item.send(self.name)
      if enumeration.first.is_a?(Array)
        key_value_pair = enumeration_key_for(content)
        content = key_value_pair.first if key_value_pair
      end
      content = content && !content.blank? ? content : self.unassigned_value
      content = wrap_with_link(content, view, item)
    else
      render_content(view, item)
    end
  end
  
  def enumeration
    if @enumeration.is_a?(Hash)
      # convert the enumeration to a sorted 2d array if it's a hash
      @enumeration.to_a.sort { |x,y| x.to_s <=> y.to_s }
    elsif @enumeration
      # convert the enumeration to a 2d array of it's a 1d array, otherwise leave it alone
      @enumeration.first.is_a?(Array) ? @enumeration : @enumeration.inject([]) { |a,v| a << [v,v] }
    end
  end
  
  def enumeration_key_for(value)
    enumeration.detect { |e| e.last == value } 
  end
  
  def render_td_list(view, item)
    id = relationship_div_id(name, item)
    div = render_td_show(view, item)
    div = div_wrapper(id) { div } if enumeration
    div += view.link_to_function("Edit", "Streamlined.Enumerations." <<
      "open_enumeration('#{id}', this, '/#{view.controller_path}')") if enumeration && editable
    div
  end
  
  # helper method to let us apply Streamlined global edit_format_for hook
  # TODO: This method isn't spec'd
  def custom_column_value(view, model_underscore, method_name)                   
    model_instance = view.instance_variable_get("@#{model_underscore}")
    modified_value = value = model_instance.send(method_name) unless model_instance.nil?
    modified_value = get_current_default_edit_value if value.blank?
    modified_value = Streamlined.format_for_edit(modified_value)                                                                     
    value == modified_value ? nil : modified_value
  end
  
  # TODO: This method isn't spec'd
  def get_current_default_edit_value
    return if self.default_edit_value.nil?
    return self.default_edit_value.call if self.default_edit_value.is_a? Proc
    self.default_edit_value
  end
  
  # TODO: This method depends on item being in scope under the instance variable name
  #       :@#model_underscore. Yucky, but Rails' input method expects this. Revisit.
  def render_td_edit(view, item)
    if enumeration
      result = render_enumeration_select(view, item)
    elsif check_box
      result = view.check_box(model_underscore, name, html_options)
    else                                           
      custom_value = custom_column_value(view, model_underscore, name)   
      options = custom_value ? html_options.merge(:value => custom_value) : html_options
      result = view.input(model_underscore, name, options)
    end
    append_help(result)
  end
  alias :render_td_new :render_td_edit
  
  def render_enumeration_select(view, item)
    id = relationship_div_id(name, item)
    choices = enumeration.to_2d_array
    choices.unshift(unassigned_option) if column_can_be_unassigned?(parent_model, name.to_sym)
    args = [model_underscore, name, choices]
    args << {} << html_options unless html_options.empty?
    view.select(*args)
  end
end