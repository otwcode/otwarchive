module Streamlined::Helpers::FormHelper
  # If the validation_reflection plugin is available and working properly, check to see if the given 
  # column allows for a nil assignment.  If so, return the unassigned choice.  Otherwise, return nothing.
  def unassigned_if_allowed(model_class, column, items)
    choice = "<option value='nil' #{'selected' unless items}>#{column.unassigned_value}</option>"
    return choice unless model_class.respond_to?('reflect_on_validations_for')
    require 'facet/module/alias_method_chain' unless Module.respond_to?('alias_method_chain')
    return choice unless Module.respond_to?('alias_method_chain')
    model_class.reflect_on_validations_for(column.name).collect(&:macro).include?(:validates_presence_of) ? '' : choice
  end
  
  # Return a boolean based on whether or not the the given column allows for a nil assignment.
  def column_can_be_unassigned?(model, column_name)
    !column_required?(model, column_name)
  end
  
  def column_required?(model, column_name)
    return false unless model.respond_to?(:reflect_on_validations_for)
    return true if model.reflect_on_validations_for(column_name).find {|e| e.macro == :validates_presence_of }
    return true if model.reflect_on_validations_for("#{column_name}_id").find {|e| e.macro == :validates_presence_of }
    false
  end
end