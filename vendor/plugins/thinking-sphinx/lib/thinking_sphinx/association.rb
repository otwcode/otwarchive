module ThinkingSphinx
  # Association tracks a specific reflection and join to reference data that
  # isn't in the base model. Very much an internal class for Thinking Sphinx -
  # perhaps because I feel it's not as strong (or simple) as most of the rest.
  # 
  class Association
    attr_accessor :parent, :reflection, :join
    
    # Create a new association by passing in the parent association, and the
    # corresponding reflection instance. If there is no parent, pass in nil.
    # 
    #   top   = Association.new nil, top_reflection
    #   child = Association.new top, child_reflection
    # 
    def initialize(parent, reflection)
      @parent, @reflection = parent, reflection
      @children = {}
    end
    
    # Get the children associations for a given association name. The only time
    # that there'll actually be more than one association is when the
    # relationship is polymorphic. To keep things simple though, it will always
    # be an Array that gets returned (an empty one if no matches).
    #
    #   # where pages is an association on the class tied to the reflection.
    #   association.children(:pages)
    # 
    def children(assoc)
      @children[assoc] ||= Association.children(@reflection.klass, assoc, self)
    end
    
    # Get the children associations for a given class, association name and
    # parent association. Much like the instance method of the same name, it
    # will return an empty array if no associations have the name, and only
    # have multiple association instances if the underlying relationship is
    # polymorphic.
    # 
    #   Association.children(User, :pages, user_association)
    # 
    def self.children(klass, assoc, parent=nil)
      ref = klass.reflect_on_association(assoc)
      
      return [] if ref.nil?
      return [Association.new(parent, ref)] unless ref.options[:polymorphic]
      
      # association is polymorphic - create associations for each
      # non-polymorphic reflection.
      polymorphic_classes(ref).collect { |klass|
        Association.new parent, ::ActiveRecord::Reflection::AssociationReflection.new(
          ref.macro,
          "#{ref.name}_#{klass.name}".to_sym,
          casted_options(klass, ref),
          ref.active_record
        )
      }
    end
    
    # Link up the join for this model from a base join - and set parent
    # associations' joins recursively.
    #
    def join_to(base_join)
      parent.join_to(base_join) if parent && parent.join.nil?
      
      @join ||= ::ActiveRecord::Associations::ClassMethods::JoinDependency::JoinAssociation.new(
        @reflection, base_join, parent ? parent.join : base_join.joins.first
      )
    end
    
    # Returns the association's join SQL statements - and it replaces
    # ::ts_join_alias:: with the aliased table name so the generated reflection
    # join conditions avoid column name collisions.
    # 
    def to_sql
      @join.association_join.gsub(/::ts_join_alias::/,
        "#{@reflection.klass.connection.quote_table_name(@join.parent.aliased_table_name)}"
      )
    end
    
    # Returns true if the association - or a parent - is a has_many or
    # has_and_belongs_to_many.
    # 
    def is_many?
      case @reflection.macro
      when :has_many, :has_and_belongs_to_many
        true
      else
        @parent ? @parent.is_many? : false
      end
    end
    
    # Returns an array of all the associations that lead to this one - starting
    # with the top level all the way to the current association object.
    # 
    def ancestors
      (parent ? parent.ancestors : []) << self
    end
    
    def has_column?(column)
      @reflection.klass.column_names.include?(column.to_s)
    end
    
    private
    
    # Returns all the objects that could be currently instantiated from a
    # polymorphic association. This is pretty damn fast if there's an index on
    # the foreign type column - but if there isn't, it can take a while if you
    # have a lot of data.
    # 
    def self.polymorphic_classes(ref)
      ref.active_record.connection.select_all(
        "SELECT DISTINCT #{ref.options[:foreign_type]} " +
        "FROM #{ref.active_record.table_name} " +
        "WHERE #{ref.options[:foreign_type]} IS NOT NULL"
      ).collect { |row|
        row[ref.options[:foreign_type]].constantize
      }
    end
    
    # Returns a new set of options for an association that mimics an existing
    # polymorphic relationship for a specific class. It adds a condition to
    # filter by the appropriate object.
    # 
    def self.casted_options(klass, ref)
      options = ref.options.clone
      options[:polymorphic]   = nil
      options[:class_name]    = klass.name
      options[:foreign_key] ||= "#{ref.name}_id"
      
      quoted_foreign_type = klass.connection.quote_column_name ref.options[:foreign_type]
      case options[:conditions]
      when nil
        options[:conditions] = "::ts_join_alias::.#{quoted_foreign_type} = '#{klass.name}'"
      when Array
        options[:conditions] << "::ts_join_alias::.#{quoted_foreign_type} = '#{klass.name}'"
      when Hash
        options[:conditions].merge!(ref.options[:foreign_type] => klass.name)
      else
        options[:conditions] << " AND ::ts_join_alias::.#{quoted_foreign_type} = '#{klass.name}'"
      end
      
      options
    end
  end
end