# Streamlined
# (c) 2005-2008 Relevance, Inc.. (http://thinkrelevance.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlinedframework.org/
#
# The methods here are available to all Streamlined views.

module Streamlined; end
module Streamlined; module Helpers; end; end

require 'streamlined/helpers/link_helper'
require 'streamlined/helpers/layout_helper'
require 'streamlined/helpers/table_helper'
require 'streamlined/helpers/form_helper'
require 'streamlined/helpers/filter_helper'
require 'streamlined/helpers/header_helper'
require 'streamlined/helpers/breadcrumb_helper'
  
module Streamlined::Helper
  include Streamlined::Helpers::TableHelper
  include Streamlined::Helpers::LinkHelper
  include Streamlined::Helpers::LayoutHelper
  include Streamlined::Helpers::FormHelper
  include Streamlined::Helpers::FilterHelper
  include Streamlined::Helpers::HeaderHelper
  include Streamlined::Helpers::BreadcrumbHelper
  
  def self.included(includer)
    includer.class_eval do
      attr_reader :streamlined_request_context
      delegates :model_name,
                :model, 
                :model_symbol, 
                :model_table, 
                :model_underscore, 
                :model_ui,  
                {:to=>:controller}
      delegates :list_columns, :to=>:model_ui
    end
  end
  
  # Given an image file, checks to see if the image exists in the filesystem.
  # If it does, display the image. If not, suppress the generation of the image
  # tag.  Used to add model-specific icons to the UI.  If the icon does not
  # exist, ensures no broken image tag or alternate text is rendered to the page.
  def image_tag_if_exists(image, options = {})  
    image_tag(image, options) if(File.exist?File.join(RAILS_ROOT, 'public', 'images', image)) 
  end
  
  # invisible links are plucked out by unobtrusive JavaScript to add functionality
  def invisible_link_to(options = {}, html_options={}, *parms)
    link_to('', options, html_options.merge(:style=>"display:none;"), *parms)    
  end
 
#  TODO: look for spans with a popup class and layer in the JavaScript  
#  def popup_events_for_item(item, column, model_ui)
#    if model_ui.popup_columns.include?(column.name.to_sym)
#      %{onmouseover="Streamlined.Popup.show('#{url_for(:action => 'popup', :id => item.id)}');" onmouseout="nd();"} 
#    end
#  end
  
  # Creates the id for the div containing a given relationship. 
  def relationship_div_id(relationship, item, in_window = false)
    "#{model_ui.id_fragment(relationships[relationship.name], :edit)}::#{relationship.name}::#{item.id}::#{relationship.class_name}#{'::win' if in_window}"
  end
  
  # Given a template name, determines the precise location of the file to be used: model-specific view folders, or generic views
  delegate :generic_view, :to=>:controller
  
end