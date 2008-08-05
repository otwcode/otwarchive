module Streamlined::Helpers::FilterHelper
  attr_with_default(:advanced_filtering) {false}
  
  # return the columns to be used for Advanced Filter
  def advanced_filter_columns
    filter_columns = Hash.new

    model_ui.list_columns.each do |column|
      if column.is_a?(Streamlined::Column::ActiveRecord)
        filter_columns[column.human_name] = column.name 
      elsif column.is_a?(Streamlined::Column::Association)
        association_name = column.name
        # If there are fields defined for the show_view in the ModelUI file then use those
        # otherwise look for a name or title on the association and filter on that.
        # Checking against column_names ensures that they are db fields and not defines in the model.
        if model_ui.column(association_name, :crud_context => :list).show_view.fields
          model_ui.column(association_name, :crud_context => :list).show_view.fields.each do |field|
            if model.reflect_on_association(association_name).klass.column_names.index(field.to_s) 
              filter_columns[Inflector.humanize(association_name.to_s) + " (" + Inflector.humanize(field) + ")"] = "rel::" + association_name.to_s + "::" + "#{field}"
            end
          end
        else  
          names = %w{name title}
          no_name_yet = true
          names.each do |name|
            if no_name_yet && model.reflect_on_association(association_name).klass.column_names.index(name) 
              filter_columns[Inflector.humanize(association_name.to_s) + " (" + Inflector.humanize(name) + ")"] = "rel::" + association_name.to_s + "::" + "#{name}"
              no_name_yet = false
            end
          end    
        end
      end  
    end
    filter_columns.sort 
  end
  
end