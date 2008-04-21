module LocalizedUrlHelpers::NamedRouteCollectionMethods
  def self.included(base)
    base.class_eval do
      alias_method_chain :define_url_helper, :inject_locale_wrapper
    end
  end

  def define_url_helper_with_inject_locale_wrapper(route, name, kind, options)
    # define an url_helper     
    define_url_helper_without_inject_locale_wrapper(route, name, kind, options)
    # and wrap it if a segment named :locale is involved
    if route.significant_keys.include? :locale
      inject_locale_to_url_helper url_helper_name(name, kind)
    end
  end
  
  def inject_locale_to_url_helper(selector)
    # wrap newly defined url_helpers with this
    @module.send :module_eval, <<-end_eval 
      def #{selector}_with_locale(*args)   
        # when called with "ordered parameters", shift the locale into the parameter array
        args.unshift @locale unless args.empty? || Hash === args.first
        #{selector}_without_locale(*args)
      end
    end_eval
    @module.send :alias_method_chain, selector, :locale  
  end
end

module LocalizedUrlHelpers::RouteSetMethods
  def self.included(base)
    base.class_eval do
      alias_method_chain :build_expiry, :unexpire_locale
    end
  end
  
  def build_expiry_with_unexpire_locale(options, recall)
    expiry = build_expiry_without_unexpire_locale(options, recall)
    # always remove the :locale segment from the expiry hash
    expiry[:locale] = false
    expiry
  end
end