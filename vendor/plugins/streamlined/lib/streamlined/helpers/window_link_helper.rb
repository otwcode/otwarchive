# This helper provides support for using Prototype Windows to render the edit/show instead of the
# default, which is to render them as separate HTML pages. To add it, pass it as an option to the 
# +acts_as_streamlined+ method:
#
#     class PeopleController < ApplicationController
#         acts_as_streamlined :helpers => [Streamlined::Helpers::WindowLinkHelper]
#     end
#
# TODO: This class is almost identical to LinkHelper. The duplication should be refactored out.
module Streamlined::Helpers::WindowLinkHelper
  def guess_show_link_for(model)
    case model
      when Enumerable
        "(multiple)"
      when ActiveRecord::Base
        link_to(model.streamlined_name,
          :controller => model.class.name.underscore.pluralize,
          :action => "show", :id => model.id)
      when nil
        "(unassigned)"
      else 
        "(unknown)"
    end
  end
  # TODO: add unobtrusive JavaScript for:
  # Streamlined.Windows.open_local_window_from_url('New', '#{url_for(:action => 'new')}'
  def link_to_new_model
    link_to_function(image_tag('streamlined/add_16.png', 
        {:alt => "New #{model_name}", :title => "New #{model_name}", :border => '0'}),          
        "Streamlined.Windows.open_local_window_from_url('New', '#{url_for(:action => 'new')}', null)"
        ) unless model_ui.read_only || !model_ui.quick_new_button
  end

  def link_to_show_model(item)
    link_to_function(image_tag('streamlined/search_16.png', 
        {:alt => "Show #{model_name}", :title => "Show #{model_name}", :border => '0'}),          
        "Streamlined.Windows.open_local_window_from_url('Show', '#{url_for(:action => 'show', :id => item.id)}', null)")
  end

  def link_to_edit_model(item)
    link_to_function(image_tag('streamlined/edit_16.png', 
        {:alt => "Edit #{model_name}", :title => "Edit #{model_name}", :border => '0'}),          
        "Streamlined.Windows.open_local_window_from_url('Edit', '#{url_for(:action => 'edit', :id => item.id)}', null)") unless model_ui.read_only
  end

  # replaced by wrap_with_link, below, and see comment
  # def text_link_to_edit_model(column,item)
  #   link_to_function(h(item.send(column.name)),   
  #       "Streamlined.Windows.open_local_window_from_url('Edit', '#{url_for(:action => 'edit', :id => item.id)}', #{item.id})",
  #       :href => url_for(:action=>"edit", :id=>id))
  # end
  
  # TODO:
  # 1. Kill all the JavaScript code generation in links
  # 2. Move all the degradable module stuff here
  # 3. Add JavaScript to the page to make links into window creation links
  def wrap_with_link(link_args)
    if link_args.instance_of? Array
      link_to(yield, *link_args)
    else
      link_to(yield,link_args)
    end
  end

  def link_to_delete_model(item)
    link_to image_tag('streamlined/delete_16.png', {:alt => 'Destroy', :title => 'Destroy', :border => '0'}), 
        {:action => 'destroy', :id => item.id}, 
        :confirm => 'Are you sure?', :method => "post"    
  end

  def link_to_next_page
    link_to_function image_tag('streamlined/control-forward_16.png', 
        {:id => 'next_page', :alt => 'Next Page', :style => page_link_style, :title => 'Next Page', :border => '0'}),
        "Streamlined.PageOptions.nextPage()"
  end

  def link_to_previous_page
    link_to_function image_tag('streamlined/control-reverse_16.png', 
        {:id => 'previous_page', :alt => 'Previous Page', :style => page_link_style, :title => 'Previous Page', :border => '0'}),
        "Streamlined.PageOptions.previousPage()"
  end
  
  private
  def page_link_style
    !@streamlined_item_pages.empty? && @streamlined_item_pages.current.previous ? "" : "display: none;"
  end
end


