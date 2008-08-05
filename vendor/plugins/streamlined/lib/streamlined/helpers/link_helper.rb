# Helpers for creating links. Many of these links have additional functionality, implied by
# CSS classes. Streamlined.js picks up these CSS classes and adds capabilities.

# TODO: This class is almost identical to WindowLinkHelper. The duplication should be refactored out.
module Streamlined::Helpers::LinkHelper
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
  
  # Clicking on the +link+ will toggle visibility of the DOM ID +element+.
  def link_to_toggler(link, element)
    link_to(link, "\##{element}", :class => "sl_toggler")
  end
  
  # TODO: add unobtrusive JavaScript for:
  # Streamlined.Windows.open_local_window_from_url('New', '#{url_for(:action => 'new')}'
  def link_to_new_model
    link_to(image_tag('streamlined/add_16.png', 
        {:alt => "New #{model_name.titleize}", :title => "New #{model_name.titleize}", :border => '0'}),          
        :action => 'new') unless model_ui.read_only || !model_ui.quick_new_button
  end

  def link_to_show_model(item)
    link_to(image_tag('streamlined/search_16.png', 
        {:alt => "Show #{model_name.titleize}", :title => "Show #{model_name.titleize}", :border => '0'}),          
        :action => 'show', :id => item.id )
  end

  def link_to_edit_model(item)
    link_to(image_tag('streamlined/edit_16.png', 
        {:alt => "Edit #{model_name.titleize}", :title => "Edit #{model_name.titleize}", :border => '0'}),          
        :action => 'edit', :id => item.id ) unless model_ui.read_only
  end

  # replaced by wrap_with_link, below, and see comment
  # def text_link_to_edit_model(column,item)
  #   link_to_function(h(item.send(column.name)),   
  #       "Streamlined.Windows.open_local_window_from_url('Edit', '#{url_for(:action => 'edit', :id => item.id)}', #{item.id})",
  #       :href => url_for(:action=>"edit", :id=>id))
  # end
  
  # TODO:
  # 1. Move all the degradable module stuff here
  # 2. Add JavaScript to the page to make links into window creation links
  def wrap_with_link(link_args)
    if link_args.instance_of? Array
      link_to(yield, *link_args)
    else
      link_to(yield,link_args)
    end
  end

  def link_to_delete_model(item)
    id = item.id
    link_to image_tag('streamlined/delete_16.png', {:alt => 'Destroy', :title => 'Destroy', :border => '0'}), 
        {:action => 'destroy', :id => item.id }, 
        :confirm => 'Are you sure?', :method => "post"    
  end

  def link_to_next_page
    link_to_function image_tag('streamlined/control-forward_16.png', 
        {:id => 'next_page', :alt => 'Next Page', :style => @streamlined_item_pages != [] && @streamlined_item_pages.current.next ? "" : "display: none;", :title => 'Next Page', :border => '0'}),   
        "Streamlined.PageOptions.nextPage()"
  end

  def link_to_previous_page
    link_to_function image_tag('streamlined/control-reverse_16.png', 
        {:id => 'previous_page', :alt => 'Previous Page', :style => @streamlined_item_pages != [] && @streamlined_item_pages.current.previous ? "" : "display: none;", :title => 'Previous Page', :border => '0'}), 
        "Streamlined.PageOptions.previousPage()"
  end

  def link_to_toggle_export
    return '' if model_ui.displays_exporter?(:none)
    link_to_function(image_tag('streamlined/export_16.png', 
        {:alt => "Export #{model_name.titleize.pluralize}", :title => "Export #{model_name.titleize.pluralize}", :border => '0'}),          
        "Element.toggle('show_export')")
  end

  def link_to_submit_export(url_options)
    link_to_function("Export",          
        "Streamlined.Exporter.submit_export('#{url_for(url_options)}')")
  end

  def link_to_hide_export
    link_to_function("Cancel",          
    "Element.hide('show_export')")
  end

  def show_columns_to_export
    model_ui.displays_exporter?(:enhanced_xml_file) || 
    model_ui.displays_exporter?(:xml_stylesheet)    || 
    model_ui.displays_exporter?(:enhanced_xml)
  end  

  def export_formats
    content = ""
    Array(model_ui.exporters).each do |format|
      labeltext = model_ui.export_labels[format].nil? ? "" : model_ui.export_labels[format]
      content += content_tag(:label, radio_button_tag('format', labeltext.gsub("&nbsp;",""), model_ui.default_exporter?(format)) + labeltext)
    end
    content
  end
  
end