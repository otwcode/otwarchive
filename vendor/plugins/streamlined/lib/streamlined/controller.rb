# Streamlined
# (c) 2005-2008 Relevance, Inc.. (http://thinkrelevance.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlinedframework.org/
module Streamlined::Controller; end

require 'streamlined/controller/crud_methods'
require 'streamlined/controller/enumeration_methods'
require 'streamlined/controller/relationship_methods'
require 'streamlined/controller/render_methods'
require 'streamlined/controller/callbacks'
require 'streamlined/controller/quick_add_methods'
require 'streamlined/controller/filter_methods'
require 'streamlined/controller/options_methods'

module Streamlined::Controller::InstanceMethods
  include Streamlined::Controller::CrudMethods
  include Streamlined::Controller::EnumerationMethods
  include Streamlined::Controller::RenderMethods
  include Streamlined::Controller::Callbacks
  include Streamlined::Controller::RelationshipMethods
  include Streamlined::Controller::QuickAddMethods
  include Streamlined::Controller::FilterMethods
  include Streamlined::Controller::OptionsMethods
  
  def index
    list
  end
  
  # Creates the popup window for an item
  def popup
    self.instance = model.find(params[:id])
    render :partial => 'popup'
  end


  protected
  
  def instance
    self.instance_variable_get("@#{model_name.variableize}")
  end

  def instance=(value)
    self.instance_variable_set("@#{model_name.variableize}", value)
    @streamlined_item = value
  end
  
       
  private
  def initialize_request_context
    @streamlined_request_context = Streamlined::Context::RequestContext.new(params[:page_options])
  end
      
  # rewrite of rails method
  def paginator_and_collection_for(collection_id, options) #:nodoc:
    klass = model
    # page  = @params[options[:parameter]]
    page = streamlined_request_context.page
    count = count_collection_for_pagination(klass, options)
    paginator = ActionController::Pagination::Paginator.new(self, count, options[:per_page], page)
    collection = find_collection_for_pagination(klass, options, paginator)

    return paginator, collection 
  end

  def streamlined_logger
    RAILS_DEFAULT_LOGGER
  end
        
        
end

module Streamlined::Controller::ClassMethods  
  def acts_as_streamlined(options = {})
    class_eval do
      attr_reader :streamlined_request_context
      attr_with_default(:breadcrumb_trail) {[]}
      helper_method :crud_context, :render_tabs, :render_partials, :instance, :breadcrumb_trail
      delegate_non_routable(*Streamlined::Context::RequestContext::DELEGATES) 
      initialize_streamlined_controller_context(controller_name.singularize.classify)
      include Streamlined::Controller::InstanceMethods
      before_filter :initialize_request_context
      Dir["#{RAILS_ROOT}/app/streamlined/*.rb"].each do |name|
        Dependencies.depend_on name, true
      end
      # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
      verify :method => :post, :only => [ :destroy, :create, :update ],
            :redirect_to => { :action => :list }
    end
  end

  def delegate_non_routable(*delegates_args)
    delegates *delegates_args
    delegates_args.each {|arg| hide_action(arg)}
  end
  
  # controller name is passed in by acts_as_streamlined and becomes model name      
  def initialize_streamlined_controller_context(model_name)        
    class << self
      attr_reader :streamlined_controller_context 
      delegate *Streamlined::Context::ControllerContext.delegates + 
               [{:to => :streamlined_controller_context}]
    end
    @streamlined_controller_context = Streamlined::Context::ControllerContext.new(model_name)
    delegate_non_routable *Streamlined::Context::ControllerContext.delegates + 
                           [{:to => "self.class"}]
  end

  def filters
    @filters ||= {}
  end
  
  def callbacks
    @callbacks ||= {}
  end
  
  def render_filters
    filters[:render] ||= {}
  end
    
  def render_filter(action, options)
    render_filters[action] = options
  end
  
  # Declare a method or proc to be called after the instance is created (and populated with params) but before save is called
  # If the callback returns false, save will not be called.
  def before_streamlined_create(callback)
    unless callback.is_a?(Proc) || callback.is_a?(Symbol) 
      raise ArgumentError, "Invalid options for db_action_filter - must pass either a Proc or a Symbol, you gave [#{callback.inspect}]"
    end
    callbacks[:before_create] = callback
  end

  # Declare a method or proc to be called after the instance is updated (and populated with params) but before save is called
  # If the callback returns false, save will not be called.  
  def before_streamlined_update(callback)
    unless callback.is_a?(Proc) || callback.is_a?(Symbol) 
      raise ArgumentError, "Invalid options for db_action_filter - must pass either a Proc or a Symbol, you gave [#{callback.inspect}]"
    end
    callbacks[:before_update] = callback
  end
  
  def count_or_find_options(options=nil)
    return @count_or_find_options || {} unless options
    @count_or_find_options = options
  end
end
