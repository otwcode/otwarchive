# Provides a registry hook for global items that should never be reloaded 
# (e.g., items registered in environment.rb).
class Streamlined::PermanentRegistry  
  class <<self
    SUBREGISTRIES = [:display_formats_by_matcher, :edit_formats_by_matcher]
    attr_accessor *SUBREGISTRIES
    def reset
      SUBREGISTRIES.each {|s| send("#{s}=",{})}
    end      
    
    def display_format_for(matcher, &proc)
      set_format_for(:display, matcher, &proc)
    end
    
    def edit_format_for(matcher, &proc)
      set_format_for(:edit, matcher, &proc)
    end
    
    def format_for_display(object)
      format_for(:display, object)
    end

    def format_for_edit(object)
      format_for(:edit, object)
    end
    
    private
    def set_format_for(mode, matcher, &proc)
      raise ArgumentError, "Block required" unless block_given?
      send("#{mode}_formats_by_matcher")[matcher] = proc
    end                                                        

    def format_for(mode, object)
      send("#{mode}_formats_by_matcher").each do |k,v|
        if k === object
          return v.call(object)
        end
      end
      object
    end
  end
  
  reset
  
end

