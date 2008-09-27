require 'paginator'
require 'extensions'

# Squirrel is a library for making querying the database using ActiveRecord cleaner, easier
# to read, and less prone to user error. It does this by allowing AR::Base#find to take a block,
# which is run to build the conditions and includes required to execute the query.
module Squirrel
  # When included in AR::Base, it chains the #find method to allow for block execution.
  module Hook
    def find_with_squirrel *args, &blk
      args ||= [:all]
      if blk || (args.last.is_a?(Hash) && args.last.has_key?(:paginate))
        query = Query.new(self, &blk)
        query.execute(*args)
      else
        find_without_squirrel(*args)
      end
    end

    def scoped_with_squirrel *args, &blk
      if blk
        query = Query.new(self, &blk)
        self.scoped(query.to_find_parameters)
      else
        scoped_without_squirrel(*args)
      end
    end

    def self.included base
      if ! base.instance_methods.include?('find_without_squirrel') &&
           base.instance_methods.include?('find')
        base.class_eval do
          alias_method :find_without_squirrel, :find
          alias_method :find, :find_with_squirrel
        end
      end
      if ! base.instance_methods.include?('scoped_without_squirrel') &&
           base.instance_methods.include?('scoped')
        base.class_eval do
          alias_method :scoped_without_squirrel, :scoped
          alias_method :scoped, :scoped_with_squirrel
        end
      end
    end
  end

  module NamedScopeHook
    def scoped *args, &blk
      args = blk ? [Query.new(self, &blk).to_find_parameters] : args
      scopes[:scoped].call(self, *args)
    end
  end

  # The Query is what contains the query and is what handles execution and pagination of the
  # result set.
  class Query
    attr_reader :conditions, :model

    # Creates a Query specific to the given model (which is a class that descends from AR::Base)
    # and a block that will be run to find the conditions for the #find call.
    def initialize model, &blk
      @model      = model
      @joins      = nil
      @binding    = blk && blk.binding
      @conditions = ConditionGroup.new(@model, "AND", @binding, &blk)
      @conditions.assign_joins( join_dependency )
    end
    
    # Builds the dependencies needed to find what AR plans to call the tables in the query
    # by finding and sending what would be passed in as the +include+ parameter to #find.
    # This is a necessary step because what AR calls tables deeply nested might not be
    # completely obvious.)
    def join_dependency
      jd = ::ActiveRecord::Associations::ClassMethods::JoinDependency
      @join_dependency ||= jd.new model, 
                                  @conditions.to_find_include, 
                                  nil
    end

    # Runs the block which builds the conditions. If requested, paginates the result_set.
    # If the first parameter to #find is :query (instead of :all or :first), then the query
    # object itself is returned. Useful for debugging, but not much else.
    def execute *args
      if args.first == :query
        self
      else
        opts = args.last.is_a?(Hash) ? args.last : {}
        results = []
        pagination = opts.delete(:paginate) || {}
        model.send(:with_scope, :find => opts) do
          @conditions.paginate(pagination) unless pagination.empty?
          results = model.find args[0], to_find_parameters
          if @conditions.paginate?
            paginate_result_set results, to_find_parameters
          end
        end
        results
      end
    end

    def to_find_parameters
      find_parameters = {}
      find_parameters[:conditions] = to_find_conditions unless to_find_conditions.blank?
      find_parameters[:include   ] = to_find_include    unless to_find_include.blank?
      find_parameters[:order     ] = to_find_order      unless to_find_order.blank?
      find_parameters[:limit     ] = to_find_limit      unless to_find_limit.blank?
      find_parameters[:offset    ] = to_find_offset     unless to_find_offset.blank?
      find_parameters
    end

    # Delegates the to_find_conditions call to the root ConditionGroup
    def to_find_conditions
      @conditions.to_find_conditions
    end

    # Delegates the to_find_include call to the root ConditionGroup
    def to_find_include
      @conditions.to_find_include
    end

    # Delegates the to_find_order call to the root ConditionGroup
    def to_find_order
      @conditions.to_find_order
    end

    # Delegates the to_find_limit call to the root ConditionGroup
    def to_find_limit
      @conditions.to_find_limit
    end

    # Delegates the to_find_offset call to the root ConditionGroup
    def to_find_offset
      @conditions.to_find_offset
    end

    # Used by #execute to paginates the result set if 
    # pagination was requested. In this case, it adds +pages+ and +total_results+ accessors
    # to the result set. See Paginator for more details.
    def paginate_result_set set, conditions
      limit  = conditions.delete(:limit)
      offset = conditions.delete(:offset)

      class << set
        attr_reader :pages
        attr_reader :total_results
      end

      total_results = model.count(conditions)
      set.instance_variable_set("@pages", 
                                Paginator.new( :count => total_results, 
                                               :limit => limit, 
                                               :offset => offset) )
      set.instance_variable_set("@total_results", total_results)
      set.extend( Squirrel::WillPagination )
    end
    
    # ConditionGroups are groups of Conditions, oddly enough. They most closely map to models
    # in your schema, but they also handle the grouping jobs for the #any and #all blocks.
    class ConditionGroup
      attr_accessor :model, :logical_join, :binding, :reflection, :path

      # Creates a ConditionGroup by passing in the following arguments:
      # * model: The AR subclass that defines what columns and associations will be accessible
      #   in the given block.
      # * logical_join: A string containing the join that will be used when concatenating the 
      #   conditions together. The root level ConditionGroup created by Query defaults the 
      #   join to be "AND", but the #any and #all methods will create specific ConditionGroups
      #   using "OR" and "AND" as their join, respectively.
      # * binding: The +binding+ of the block passed to the original #find. Will be used to
      #   +eval+ what +self+ would be. This is necessary for using methods like +params+ and 
      #   +session+ in your controllers.
      # * path: The "path" taken through the models to arrive at this model. For example, if
      #   your User class has_many Posts which has_many Comments each of which belongs_to User,
      #   the path to the second User would be [:posts, :comments, :user]
      # * reflection: The association used to get to this block. If nil, then no new association
      #   was traversed, which means we're in an #any or #all grouping block.
      # * blk: The block to be executed.
      #
      # This method defines a number of methods to be available inside the block, one for each
      # of the columns and associations in the specified model. Note that you CANNOT use
      # user-defined methods on your model inside Squirrel queries. They don't have any meaning
      # in the context of a database query.
      def initialize model, logical_join, binding, path = nil, reflection = nil, &blk
        @model            = model
        @logical_join     = logical_join
        @conditions       = []
        @condition_blocks = []
        @reflection       = reflection
        @path             = [ path, reflection ].compact.flatten
        @binding          = binding
        @order            = []
        @negative         = false
        @paginator        = false
        @block            = blk

        existing_methods = self.class.instance_methods(false)
        (model.column_names - existing_methods).each do |col|
          (class << self; self; end).class_eval do
            define_method(col.to_s.intern) do
              column(col)
            end
          end
        end
        (model.reflections.keys - existing_methods).each do |assn|
          (class << self; self; end).class_eval do
            define_method(assn.to_s.intern) do
              association(assn)
            end
          end
        end

        execute_block
      end

      # Creates a Condition and queues it for inclusion. When calling a method defined
      # during the creation of the ConditionGroup object is the same as calling column(:column_name).
      # This is useful if you need to access a column that happens to coincide with the name of
      # an already-defined method (e.g. anything returned by instance_methods(false) for the
      # given model).
      def column name
        @conditions << Condition.new(name)
        @conditions.last
      end

      # Similar to #column, this will create an association even if you can't use the normal
      # method version.
      def association name, &blk
        name = name.to_s.intern
        ref = @model.reflect_on_association(name)
        @condition_blocks << ConditionGroup.new(ref.klass, logical_join, binding, path, ref.name, &blk)
        @condition_blocks.last
      end

      # Creates a ConditionGroup that has the logical_join set to "OR".
      def any &blk
        @condition_blocks << ConditionGroup.new(model, "OR", binding, path, &blk)
        @condition_blocks.last
      end

      # Creates a ConditionGroup that has the logical_join set to "AND".
      def all &blk
        @condition_blocks << ConditionGroup.new(model, "AND", binding, path, &blk)
        @condition_blocks.last
      end
      
      # Sets the arguments for the :order parameter. Arguments can be columns (i.e. Conditions)
      # or they can be strings (for "RANDOM()", etc.). If a Condition is used, and the column is
      # negated using #not or #desc, then the resulting specification in the ORDER clause will 
      # be ordered descending. That is, "order_by name.desc" will become "ORDER name DESC"
      def order_by *columns
        @order += [columns].flatten
      end
      
      # Flags the result set to be paginated according to the :page and :per_page parameters
      # to this method.
      def paginate opts = {}
        @paginator = true
        page     = (opts[:page]     || 1).to_i
        per_page = (opts[:per_page] || 20).to_i
        page     = 1 if page < 1
        limit( per_page, ( page - 1 ) * per_page )
      end
      
      # Similar to #paginate, but does not flag the result set for pagination. Takes a limit
      # and an offset (by default the offset is 0).
      def limit lim, off = nil
        @limit  = ( lim || @limit ).to_i
        @offset = ( off || @offset ).to_i
      end
      
      # Returns true if this ConditionGroup or any of its subgroups have been flagged for pagination.
      def paginate?
        @paginator || @condition_blocks.any?(&:paginate?)
      end
      
      # Negates the condition. Essentially prefixes the condition with NOT in the final query.
      def -@
        @negative = !@negative
        self
      end

      alias_method :desc, :-@

      # Negates the condition. Also works to negate ConditionGroup blocks in a more straightforward
      # manner, like so:
      #   any.not do
      #     id == 1
      #     name == "Joe"
      #   end
      # 
      #   # => "NOT( id = 1 OR name = 'Joe')"
      def not &blk
        @negative = !@negative
        if blk
          @block = blk
          execute_block
        end
      end

      # Takes the JoinDependency object and filters it down through the ConditionGroups
      # to make sure each one knows the aliases necessary to refer to each table by its
      # correct name.
      def assign_joins join_dependency, ancestries = nil
        ancestries ||= join_dependency.join_associations.map{|ja| ja.ancestry }
        unless @conditions.empty?
          my_association = unless @path.blank?
                             join_dependency.join_associations[ancestries.index(@path)]
                           else 
                             join_dependency.join_base
                           end
          @conditions.each do |column|
            column.assign_join(my_association)
          end
        end
        @condition_blocks.each do |association|
          association.assign_joins(join_dependency, ancestries)
        end
      end

      # Generates the parameter for :include for this ConditionGroup and all its subgroups.
      def to_find_include
        @condition_blocks.inject({}) do |inc, cb|
          if cb.reflection.nil?
            inc.merge_tree(cb.to_find_include)
          else
            inc[cb.reflection] ||= {}
            inc[cb.reflection] = inc[cb.reflection].merge_tree(cb.to_find_include)
            inc
          end
        end
      end
      
      # Generates the :order parameter for this ConditionGroup. Because this does not reference
      # subgroups it should only be used from the outermost block (which is probably where it makes
      # the most sense to reference it, but it's worth mentioning)
      def to_find_order
        if @order.blank?
          nil
        else
          @order.collect do |col| 
            col.respond_to?(:full_name) ? (col.full_name + (col.negative? ? " DESC" : "")) : col 
          end.join(", ")
        end
      end

      # Generates the :conditions parameter for this ConditionGroup and all subgroups. It
      # generates them in ["sql", params] format because of the requirements of LIKE, etc.
      def to_find_conditions
        segments = conditions.collect{|c| c.to_find_conditions }.compact
        return nil if segments.length == 0
        cond = "(" + segments.collect{|s| s.first }.join(" #{logical_join} ") + ")"
        cond = "NOT #{cond}" if negative?
        
        values = segments.inject([]){|all, now| all + now[1..-1] }
        [ cond, *values ]
      end

      # Generates the :limit parameter.
      def to_find_limit
        @limit
      end

      # Generates the :offset parameter.
      def to_find_offset
        @offset
      end

      # Returns all the conditions, which is the union of the Conditions and ConditionGroups
      # that belong to this ConditionGroup.
      def conditions
        @conditions + @condition_blocks
      end
      
      # Returns true if this block has been negated using #not, #desc, or #-
      def negative?
        @negative
      end

      # This is a bit of a hack, due to how Squirrel is built. It can be used to fetch
      # instance variables from the location where the call to #find was made. For example,
      # if called from within your model and you happened to have an instance variable called
      # "@foo", you can access it by calling
      #   instance "@foo"
      # from within your Squirrel query.
      def instance instance_var
        s = eval("self", binding)
        if s
          s.instance_variable_get(instance_var)
        end
      end

      private

      def execute_block #:nodoc:
        instance_eval &@block if @block
      end

      def method_missing meth, *args #:nodoc:
        m = eval <<-end_eval, binding
          begin
            method(:#{meth})
          rescue NameError
            nil
          end
        end_eval
        if m
          m.call(*args)
        else
          super(meth, *args)
        end
      end

    end

    # Handles comparisons in the query. This class is analagous to the columns in the database.
    # When comparing the Condition to a value, the operators are used as follows:
    # * ==, === : Straight-up Equals. Can also be used as the "IN" operator if the operand is an Array.
    #   Additionally, when the oprand is +nil+, the comparison is correctly generates as "IS NULL"."
    # * =~ : The LIKE and REGEXP operators. If the operand is a String, it will generate a LIKE
    #   comparison. If it is a Regexp, the REGEXP operator will be used. NOTE: MySQL regular expressions
    #   are NOT the same as Ruby regular expressions. Also NOTE: No wildcards are inserted into the LIKE
    #   comparison, so you may add them where you wish.
    # * <=> : Performs a BETWEEN comparison, as long as the operand responds to both #first and #last,
    #   which both Ranges and Arrays do.
    # * > : A simple greater-than comparison.
    # * >= : Greater-than or equal-to.
    # * < : A simple less-than comparison.
    # * <= : Less-than or equal-to.
    # * contains? : Like =~, except automatically surrounds the operand in %s, which =~ does not do.
    # * nil? : Works exactly like "column == nil", but in a nicer syntax, which is what Squirrel is all about.
    class Condition
      attr_reader :name, :operator, :operand

      # Creates and Condition with the given name.
      def initialize name
        @name = name
        @sql = nil
        @negative = false
      end

      [ :==, :===, :=~, :<=>, :<=, :<, :>, :>= ].each do |op|
        define_method(op) do |val|
          @operator = op
          @operand = val
          self
        end
      end

      def contains? val #:nodoc:
        @operator = :contains
        @operand = val
        self
      end

      def nil? #:nodoc:
        @operator = :==
        @operand = nil
        self
      end
      
      def -@ #:nodoc:
        @negative = !@negative
        self
      end

      alias_method :not, :-@
      alias_method :desc, :-@

      # Returns true if this Condition has been negated, which means it will be prefixed with "NOT"
      def negative?
        @negative
      end
      
      # Gets the name of the table that this Condition refers to by taking it out of the
      # association object.
      def assign_join association = nil
        @table_alias = association ? "#{association.aliased_table_name}." : ""
      end
  
      # Returns the full name of the column, including any assigned table alias.
      def full_name
        "#{@table_alias}#{name}"
      end

      # Generates the :condition parameter for this Condition, in ["sql", args] format.]
      def to_find_conditions(join_association = {})
        return nil if operator.nil?
        
        op, arg_format, values = operator, "?", [operand]
        op, arg_format, values = case operator
        when :<=>        then    [ "BETWEEN", "? AND ?",   [ operand.first, operand.last ] ]
        when :=~         then
          case operand
          when String    then    [ "LIKE",    arg_format,  values ]
          when Regexp    then    [ "REGEXP",  arg_format,  values.map(&:source) ]
          end
        when :==, :===   then
          case operand
          when Array     then    [ "IN",      "(?)",             values ]
          when Range     then    [ "IN",      "(?)",             values ]
          when Condition then    [ "=",       operand.full_name, [] ] 
          when nil       then    [ "IS",      "NULL",            [] ]
          else                   [ "=",       arg_format,        values ]
          end
        when :contains   then    [ "LIKE",    arg_format,        values.map{|v| "%#{v}%" } ]
        else
          case operand
          when Condition then    [ op,        oprand.full_name,  [] ] 
          else                   [ op,        arg_format,        values ]
          end
        end		
        sql = "#{full_name} #{op} #{arg_format}"
        sql = "NOT (#{sql})" if @negative
        [ sql, *values ]
      end

    end
  end
end
