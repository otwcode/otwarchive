# render overrides shared by controllers and views   
module Streamlined::GenericView
  protected
  def generic_view(template)
    test = Proc.new do |*args|
      file = File.join(*args)
      File.exist?(file) && file
    end
    test[STREAMLINED_GENERIC_OVERRIDE_ROOT, "#{template}.rhtml"] ||
    test[STREAMLINED_GENERIC_OVERRIDE_ROOT, "#{template}.html.erb"] ||
    test[STREAMLINED_GENERIC_OVERRIDE_ROOT, "#{template}.rxml"] ||
    test[STREAMLINED_GENERIC_OVERRIDE_ROOT, "#{template}.xml.erb"] ||
    test[STREAMLINED_GENERIC_OVERRIDE_ROOT, "#{template}.rjs"]
    test[STREAMLINED_GENERIC_VIEW_ROOT, "#{template}.rhtml"] ||
    test[STREAMLINED_GENERIC_VIEW_ROOT, "#{template}.html.erb"] ||
    test[STREAMLINED_GENERIC_VIEW_ROOT, "#{template}.rxml"] ||
    test[STREAMLINED_GENERIC_VIEW_ROOT, "#{template}.xml.erb"] ||
    test[STREAMLINED_GENERIC_VIEW_ROOT, "#{template}.rjs"]
  end
end

module Streamlined::RenderMethods
  include Streamlined::GenericView
  private
                 
  def render_streamlined_file(file, options={})
    render({:file => File.join(STREAMLINED_TEMPLATE_ROOT,file), :use_full_path => false}.merge(options))
  end
  
  def managed_views_include?(action)
    managed_views.include?(action)
  end
  
  def managed_partials_include?(action)
    managed_partials.include?(action)
  end
  
  def managed_partials
    ['list', 'form', 'popup', 'quick_add_errors']
  end
                             
  def managed_views
    ['list', 'new', 'show', 'edit', 'quick_add', 'save_quick_add', 'update_filter_select']
  end  
  
  # Returns true if the given template exists under <tt>app/views</tt>.
  # The template name can optionally include an extension.  If an extension
  # is not provided, <tt>rhtml</tt> and <tt>.html.haml</tt> will be used by default.
  def specific_template_exists?(template)
    template, extension = template.split('.')
    path = File.join(RAILS_ROOT, "app/views", template)
    if extension.blank?
      File.exist?("#{path}.rhtml") || File.exist?("#{path}.html.haml")
    else
      File.exist?("#{path}.#{extension}")
    end
  end
  
  def convert_default_options(options)
    options = { :update => true } if options == :update
    options = {:action=>action_name} if options.empty?
    options
  end
  
  def convert_action_options(options)
    action = options[:action]
    if action && managed_views_include?(options[:action])
      unless specific_template_exists?("#{controller_path}/#{options[:action]}")
        options.delete(:action)
        options[:layout] = true unless options.has_key?(:layout)
        options[:use_full_path] = false
        options[:file] = Pathname.new(generic_view(action)).expand_path.to_s
      end
    end
    options
  end
  
  def convert_all_options(options)
    options = convert_default_options(options)
    options = convert_action_options(options)
    options = convert_partial_options(options)
  end
  
  def current_action
    params[:action].intern
  end
end
