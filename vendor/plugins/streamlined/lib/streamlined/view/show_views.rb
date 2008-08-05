module Streamlined::View::ShowViews
  
  # Factory method for creating a relationship Summary given the name of a summary.
  def self.create_summary(sym, options = {})
    raise ArgumentError unless Symbol === sym
    Class.class_eval(Inflector.camelize(sym.to_s)).new options
  end

  # TODO: this is not very dry!
  class Link < Streamlined::View::Base

  end      
  
  # Renders a count of the total number of members of this collection.
  class Count < Streamlined::View::Base
    
  end
  
  # Renders a list of values, as defined by the #fields attribute.  For each member of the collection, renders those 
  # fields in a concatenated string.
  class List < Streamlined::View::Base

  end
  
  # Renders the sum of a given attribute of the related @models.  The field is specified as the single member of the #fields attribute.
  class Sum < Streamlined::View::Base

  end
  
  # Renders the average of a given attribute of the related @models.  The field is specified as the single member of the #fields attribute.
  class Average < Streamlined::View::Base

  end
  
  # Renders the streamlined_name of the other end of the relationship.  Used for n-to-one relationships.
  class Name < Streamlined::View::Base
    
  end
  
  # Renders the enumeration value.
  class Enumeration < Streamlined::View::Base
    
  end
  
  class Graph < Streamlined::View::Base
    def must_have_sparklines!
      raise "STREAMLINED ERROR: Cannot use the Sparklines Graph relationship summary: need to install Sparklines plugin first (requires RMagick, which is not the easiest thing to install, we're just warning you)" unless 'Sparklines'.to_const
    end
                                   
    # TODO: refactor pie calculation into AR helper method
    # TODO: should invalid chart type raise an error?
    # TODO: graph demo in sport project                            
    def graph_data(item, relationship)
      must_have_sparklines!
      if block_given?
        return yield(item, relationship)
      else
        case @options[:type].to_sym
        when :pie
          return [(item.send(relationship.name).size.to_f/relationship.klass.count.to_f)*100]
        else
          return [0]
        end
      end
    end
    
    def graph_options
      @options
    end
  end
  
end
