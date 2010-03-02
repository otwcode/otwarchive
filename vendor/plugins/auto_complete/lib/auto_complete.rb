module AutoComplete      
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  #
  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     auto_complete_for :post, :title
  #   end
  #
  #   # View
  #   <%= text_field_with_auto_complete :post, title %>
  #
  # By default, auto_complete_for limits the results to 10 entries,
  # and sorts by the given field.
  # 
  # auto_complete_for takes a third parameter, an options hash to
  # the find method used to search for the records:
  #
  #   auto_complete_for :post, :title, :limit => 15, :order => 'created_at DESC'
  #
  # For help on defining text input fields with autocompletion, 
  # see ActionView::Helpers::JavaScriptHelper.
  #
  # For more examples, see script.aculo.us:
  # * http://script.aculo.us/demos/ajax/autocompleter
  # * http://script.aculo.us/demos/ajax/autocompleter_customized
  module ClassMethods
    def auto_complete_for(object, method, options = {})
      define_method("auto_complete_for_#{object}_#{method}") do
        model = object.to_s.camelize.constantize
        find_options = { 
          :conditions => [ "LOWER(#{model.quoted_table_name}.#{method}) LIKE ?", '%' + params[object][method].downcase + '%' ],
          :order => "#{model.quoted_table_name}.#{method} ASC",
          :limit => 10 }.merge!(options)
        
        @items = model.scoped(find_options)
        @items = yield(@items, params) if block_given?

        render :inline => "<%= auto_complete_result @items, '#{method}' %>"
      end
    end
  end
  
end
