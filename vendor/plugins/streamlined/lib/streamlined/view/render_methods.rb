module Streamlined::View::RenderMethods
  include Streamlined::RenderMethods
  def controller_name
    controller.controller_name # needed by Streamlined::RenderMethods
  end
  
  def controller_path
    controller.controller_path # needed by Streamlined::RenderMethods
  end
  def convert_partial_options(options)
    partial = options[:partial]
    if partial && managed_partials_include?(partial)
      unless specific_template_exists?("#{controller_path}/_#{partial}")
        options.delete(:partial)        
        options[:use_full_path] = false
        options[:file] = generic_view("_#{partial}")
        generic_views_rendered << options[:file]
        options[:layout] = false unless options.has_key?(:layout)
      end
    end
    options
  end
  def render_with_streamlined(options = {}, old_local_assigns = {}, &block)
    options = convert_all_options(options)
    render_without_streamlined(options, old_local_assigns, &block)
  end
  def self.included(base)
    base.alias_method_chain :render, :streamlined
  end
  
  def generic_views_rendered
    @generic_views_rendered ||= []
  end
end




  
