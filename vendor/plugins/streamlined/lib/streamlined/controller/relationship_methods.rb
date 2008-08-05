module Streamlined::Controller::RelationshipMethods
  
 # Shows the relationship's configured +Edit+ view, as defined in streamlined_ui 
 # and Streamlined::Column.
 def edit_relationship
   self.instance = @root = model.find(params[:id])
   @rel_name = params[:relationship]
   relationship = context_column(@rel_name)
   set_items_and_all_items(relationship)
   render(:file => relationship.edit_view.partial, :use_full_path => false,
          :locals => {:relationship => relationship})
 end

 # Show's the relationship's configured +Show+ view, 
 # as defined in streamlined_ui and Streamlined::Column.
 def show_relationship
   self.instance = @root = model.find(params[:id])
   relationship = context_column(params[:relationship])
   render_show_view_partial(relationship, @root)
 end

 def render_show_view_partial(relationship, item)
   render(:file => relationship.show_view.partial, :use_full_path => false,
          :locals => {:item => item, :relationship => relationship,
                      :streamlined_def => relationship.show_view})
 end

 # Add new items to the given relationship collection. Used by the #membership view, as 
 # defined in Streamlined::Column.
 def update_relationship
    self.instance = current_row = model.find(params[:id])
    relationship_name = params[:rel_name].to_sym
    klass = params[:klass].constantize
    relationship = context_column(relationship_name)
    
    items_to_add = extract_ids_of_checked_items_from_hash(params[:item])
    current_row.send(relationship_name).replace(klass.find(items_to_add))
    
    if relationship.edit_view.respond_to?(:render_on_update)
      render_on_update(relationship_name, current_row, relationship, params[:filter])
    else
      render(:nothing => true)
    end
 end

 def render_on_update(relationship_name, current_row, relationship, filter_param)
    @rel_name = relationship_name
    @root = current_row
    @current_id = current_row.id
    set_items_and_all_items(relationship, filter_param)
    render_or_redirect(:success, relationship.edit_view.render_on_update(relationship_name, @current_id))
 end
 
 # Add new items to the given relationship collection. Used by the #membership view, as 
 # defined in Streamlined::Column.
 def update_n_to_one
  item = params[:item]
  self.instance = model.find(params[:id])
  rel_name = "#{params[:rel_name]}=".to_sym
  if item == 'nil' || item == nil
    instance.send(rel_name, nil)
  else
    if item.include?('::')
      item_id, item_name = item.split('::')
      new_item = Class.class_eval(item_name).find(item_id)
    else
      new_item = Class.class_eval(params[:klass]).find(item)
    end
    instance.send(rel_name, new_item)
  end
  instance.save
  render(:nothing => true)
 end
 
 private
 def set_items_and_all_items(relationship, item_filter = nil)
    @items = instance.send(@rel_name)
    if relationship.associables.size == 1
      @klass = Class.class_eval(params[:klass])
      @klass_ui = Streamlined.ui_for(params[:klass])
      if item_filter
        @all_items = @klass.find(:all, :conditions => @klass.conditions_by_like(item_filter))
      else            
        @all_items = @klass.find(:all)
      end
    else
      @all_items = {}
      relationship.associables.each do |klass|
        if item_filter
          @all_items[klass.name] = klass.find(:all, :conditions => klass.conditions_by_like(item_filter))
        else
          @all_items[klass.name] = klass.find(:all)
        end
      end
    end
 end
 
 def context_column(rel_name)
   model_ui.column(rel_name, :crud_context => crud_context)
 end
 
 def extract_ids_of_checked_items_from_hash(items)
   items ? items.collect{|k,v| k if v=='on'}.reject{|i| i==nil} : []
 end
 
end