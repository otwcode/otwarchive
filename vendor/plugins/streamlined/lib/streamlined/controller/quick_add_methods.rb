module Streamlined::Controller::QuickAddMethods
  
  # TODO: needs refactoring
  def quick_add
    self.crud_context = :new
    return unless set_instance_vars
    @model.class.delegate_target_associations.each do |assoc| 
      target_class = assoc.class_name.constantize
      instance_variable_set("@#{target_class.name.variableize}", target_class.new)
    end
    self.instance = @model
    render_or_redirect(:success, 'quick_add')
  end
  
  # TODO: needs refactoring
  def save_quick_add
    return unless set_instance_vars
    @object_name = get_object_name(@model)
    @success = true  
    name = @model.send(params[:model_name_method].blank? ? 'name' : params[:model_name_method])
    
    @model.class.delegate_target_associations.each do |assoc| 
      target_class = assoc.class_name.constantize
      assoc_name = assoc.class_name.variableize.to_sym
      assoc_model = target_class.new(params[assoc_name])
      @success = assoc_model.save && @success
      instance_variable_set("@#{assoc_name}", assoc_model)
      @model.send("#{assoc_name}=", assoc_model)
    end
    @success = @model.save && @success
    self.instance = @model
    render_or_redirect(:success, 'save_quick_add')
  end

  protected
  # Deprecated!! Do not use - needed for legacy reasons.
  def model_name_method_white_list
    Streamlined::Controller::QuickAddMethods.model_name_method_white_list
  end

  class << self
    attr_accessor :model_name_method_white_list
  end
  self.model_name_method_white_list ||= ["name"]
  
  private
  # this is a gross hack to work around the fact that streamlined
  # passes a method name as a form param
  def get_object_name(model)
    object_name_method = params[:model_name_method].blank? ? 'name' : params[:model_name_method] 
    raise ArgumentError, "Name method #{object_name_method} is not on the quick add method whitelist." unless model_name_method_white_list.member?(object_name_method)
    model.send(object_name_method)
  end
                       
  # for convenience you can instantiate any ActiveRecord
  # in a better world this would be whitelist of some kind?
  def safe_to_instantiate?(name)
    name.constantize.ancestors.include? ActiveRecord::Base
  rescue NameError
    false
  end
  # Setup for quick add, and ultimately return _something_ if its a valid quick add
  def set_instance_vars
    unless safe_to_instantiate?(params[:model_class_name])
      render({ :text => nil, :status => 403})
      return
    end
    @model_class_name = params[:model_class_name]
    @model_name = @model_class_name.underscore   
    model_args = params[@model_name.to_sym]
    Streamlined::Components::Select.purge_streamlined_select_none_from_params(model_args) 
    @model = @model_class_name.constantize.new(model_args)
    @ui = Streamlined.ui_for(@model.class)
    instance_variable_set("@#{@model_name}", @model)
  end
 
end