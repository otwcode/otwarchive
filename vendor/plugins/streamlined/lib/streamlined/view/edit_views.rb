module Streamlined::View::EditViews
  def self.create_relationship(sym, options = {})
    raise ArgumentError unless Symbol === sym
    Class.class_eval(Inflector.camelize(sym.to_s)).new options
  end  

  # Factory method for creating a relationship View given the name of a view.
  # Renders an Ajax-enabled table, with add/edit/delete capabilities.
  class InsetTable < Streamlined::View::Base
    
  end
  
  # Renders an Ajax-enabled checkbox list for managing which items belong to the collection.
  class Membership < Streamlined::View::Base
    
  end
  
  # Like Membership, but lists all possibles from multiple polymorphic associables
  class PolymorphicMembership < Streamlined::View::Base
    
  end
  
  # Renders an Ajax-enabled table in a JavaScript window.
  class Window < Streamlined::View::Base
    def partial
      File.join(STREAMLINED_TEMPLATE_ROOT, "relationships/edit_views/_inset_table.rhtml")
    end
  end
  
  # Renders a select box with all possible values plus "unassigned". Used for n-to-one relationships.
  class Select < Streamlined::View::Base
    
  end
  
  # Like Select, but lists all possibles from multiple polymorphic associables
  class PolymorphicSelect < Streamlined::View::Base
    
  end
  
  # Like Select, but lists all possibles from an enumeration
  class EnumerableSelect < Streamlined::View::Base
    
  end
  
  # Like Membership, but with two distinct groups of checkboxes and an autofilter field
  class FilterSelect < Streamlined::View::Base
    def render_on_update(rel_name, id)
      @rel_name = rel_name
      @current_id = id
      "update_filter_select"
    end
  end
  
end

