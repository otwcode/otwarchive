# Bootstrap the Streamlined Environment
module Streamlined::Environment
  class << self
    
    # Helper method to require plugins Streamlined depends on
    def require_streamlined_plugin(plugin)
      plugin_path = File.expand_path(File.join(File.dirname(__FILE__), "../../vendor/plugins", plugin.to_s))
      $LOAD_PATH << File.join(plugin_path, "lib")
      require File.join(plugin_path, "init.rb")
    end
    
    # Initialize constants needed throughout Streamlined
    def init_streamlined_constants
      Object.const_set("STREAMLINED_ROOT", find_streamlined_root)
      Object.const_set("STREAMLINED_TEMPLATE_ROOT", find_template_root)
      Object.const_set("STREAMLINED_GENERIC_VIEW_ROOT", "#{STREAMLINED_TEMPLATE_ROOT}/generic_views")
      Object.const_set("STREAMLINED_GENERIC_OVERRIDE_ROOT", File.join('..', 'streamlined', 'views'))
      Object.const_set("STREAMLINED_SELECT_NONE", "__streamlined_select_none__")
    end
    
    # Use an absolute path for the Streamlined root if at all possible; otherwise use a relative path
    def find_streamlined_root
      path = Pathname.new(RAILS_ROOT).join("vendor/plugins/streamlined")
      streamlined_root = path.directory? ? path : Pathname.new(__FILE__).join("../../..")
      streamlined_root.expand_path.to_s
    end
    
    # Find the streamlined template root -- we use a relative path here to stay compatible with Rails 1.2.x
    def find_template_root
      File.join(STREAMLINED_ROOT, "templates")
    end
  
    # Bootstrap the Streamlined environment
    def init_environment
      init_streamlined_constants
      # Streamlined depends on classic pagination, so we just require the plugin itself
      # to avoid deprecation warnings in 1.2.x or errors in 2.x.
      require_streamlined_plugin(:classic_pagination)
    end
  end

end

Streamlined::Environment.init_environment # Just do it, brah!
