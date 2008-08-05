module Streamlined::Controller::EnumerationMethods
  # Shows the enumeration's configured +Edit+ view, as defined in streamlined_ui 
  # and Streamlined::Column.
  def edit_enumeration
    self.instance = model.find(params[:id])
    @enumeration_name = params[:enumeration]
    rel_type = model_ui.scalars[@enumeration_name.to_sym]
    @all_items = rel_type.enumeration.to_2d_array
    @selected_item = instance.send(@enumeration_name)
    render(:file => rel_type.edit_view.partial, :use_full_path => false,
           :locals => {:item => instance, :relationship => rel_type})
  end

  # Show's the enumeration's configured +Show+ view, 
  # as defined in streamlined_ui and Streamlined::Column.
  def show_enumeration
    self.instance = model.find(params[:id])
    rel_type = model_ui.scalars[params[:enumeration].to_sym]
    render(:file => rel_type.show_view.partial, :use_full_path => false,
           :locals => {:item => instance, :relationship => rel_type})
  end

  # Select an item in the given enumeration. Used by the #enumerable view, as 
  # defined in Streamlined::Column.
  def update_enumeration
    self.instance = model.find(params[:id])
    item = (params[:item] == 'nil') ? nil : params[:item]
    instance.update_attribute(params[:rel_name], item)
    render(:nothing => true)
  end
end
