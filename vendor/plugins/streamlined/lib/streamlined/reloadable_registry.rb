class Streamlined::ReloadableRegistry
  # unloadable is needed so that we do not lose validation_reflection when
  # reloading in development mode
  unloadable
  
  @ui_by_name = {}
  @context_hashes_by_name = {}
  
  class <<self
    attr_accessor :ui_by_name
    # Returns the UI class for a given model class or name
    def ui_for(model, options = {})
      return ui_for_special_context(model, options[:context]) if options[:context]
      name = model.to_s
      @ui_by_name[name] ||= Streamlined::UI.new(model)
    end                                       
    def ui_for_special_context(model, context)
      name = model.to_s
      @context_hashes_by_name[name] ||= {}
      @context_hashes_by_name[name][context] ||= Streamlined::UI.new(model)
    end
    def reset
      @ui_by_name = {}
    end
  end
end

