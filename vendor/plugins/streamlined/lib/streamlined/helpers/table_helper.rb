module Streamlined::Helpers::TableHelper
  def streamlined_table_row_button_header
    model_ui.table_row_buttons ? "<th>&nbsp;</th>" : ""
  end
  
  def streamlined_table_row_buttons(item)
    if model_ui.table_row_buttons
      "<td>#{quick_show_button(item)}#{quick_edit_button(item)}#{quick_delete_button(item)}&nbsp;</td>"
    else
      ""
    end
  end
  
  def quick_delete_button(item)
    if model_ui.quick_delete_button
      " #{link_to_delete_model(item)}"
    else
      ""
    end
  end
  
  def quick_edit_button(item)
    if model_ui.quick_edit_button
      " #{link_to_edit_model(item)}"
    else
      ""
    end
  end
  
  def quick_show_button(item)
    if model_ui.quick_show_button
      " #{link_to_show_model(item)}"
    else
      ""
    end
  end
  
  def streamlined_filter
    if model_ui.show_table_filter?
  	  "<div><form><label for='streamlined_filter_term'>Filter:</label>  <input type='text' name='streamlined_filter_term' id='streamlined_filter_term'></form></div>"
    else
      ""
    end
  end
end