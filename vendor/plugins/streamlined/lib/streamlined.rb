# The module must be defined before we start adding in functionality
module Streamlined; end;

require 'streamlined/environment'
require 'streamlined/context'
require 'streamlined/render_methods'
require 'streamlined/breadcrumb'
require 'streamlined/column'
require 'streamlined/components'
require 'streamlined/ui'
require 'streamlined/controller'
require 'streamlined/helper'
require 'streamlined/permanent_registry'
require 'streamlined/reloadable_registry'

module Streamlined
  class Error < RuntimeError; end
  
  def self.ui_for(model, options = {}, &blk)
    ui = Streamlined::ReloadableRegistry.ui_for(model, options  )
    ui.instance_eval(&blk) if block_given?
    ui
  end 
   
  # There might be a better way to test for Edge Rails, but this is good for now.
  def self.edge_rails?
    ActionController::Base.respond_to? :view_paths=
  end
     
  class << self
    delegates :display_format_for, :format_for_display, :edit_format_for, :format_for_edit,
              :to => "Streamlined::PermanentRegistry"
  end
end

# have to do this to provide acts_as_streamlined
ActionController::Base.class_eval do 
  extend Streamlined::Controller::ClassMethods
end

# TODO: move as many helper methods as possible out of here and into UI classes
#       or registry, reducing chance of name collision with non-streamlined code.
ActionView::Base.send :include, Streamlined::Helper

# This changes Rails rendering to check the streamlined templates if no actual
# template is provided
ActionView::Base.send :include, Streamlined::View::RenderMethods

