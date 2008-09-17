module ThinkingSphinx
  class Index
    # Instances of this class represent database columns and the stack of
    # associations that lead from the base model to them.
    # 
    # The name and stack are accessible through methods starting with __ to
    # avoid conflicting with the method_missing calls that build the stack.
    # 
    class FauxColumn
      # Create a new column with a pre-defined stack. The top element in the
      # stack will get shifted to be the name value.
      # 
      def initialize(*stack)
        @name  = stack.pop
        @stack = stack
      end
      
      def self.coerce(columns)
        case columns
        when Symbol, String
          FauxColumn.new(columns)
        when Array
          columns.collect { |col| FauxColumn.coerce(col) }
        when FauxColumn
          columns
        else
          nil
        end
      end
      
      # Can't use normal method name, as that could be an association or
      # column name.
      # 
      def __name
        @name
      end
      
      # Can't use normal method name, as that could be an association or
      # column name.
      # 
      def __stack
        @stack
      end
      
      # Returns true if the stack is empty *and* if the name is a string -
      # which is an indication that of raw SQL, as opposed to a value from a
      # table's column.
      # 
      def is_string?
        @name.is_a?(String) && @stack.empty?
      end
      
      # This handles any 'invalid' method calls and sets them as the name,
      # and pushing the previous name into the stack. The object returns
      # itself.
      # 
      # If there's a single argument, it becomes the name, and the method
      # symbol goes into the stack as well. Multiple arguments means new
      # columns with the original stack and new names (from each argument) gets
      # returned.
      # 
      # Easier to explain with examples:
      # 
      #   col = FauxColumn.new :a, :b, :c
      #   col.__name  #=> :c
      #   col.__stack #=> [:a, :b]
      # 
      #   col.whatever #=> col
      #   col.__name  #=> :whatever
      #   col.__stack #=> [:a, :b, :c]
      #
      #   col.something(:id) #=> col
      #   col.__name  #=> :id
      #   col.__stack #=> [:a, :b, :c, :whatever, :something]
      #
      #   cols = col.short(:x, :y, :z)
      #   cols[0].__name  #=> :x
      #   cols[0].__stack #=> [:a, :b, :c, :whatever, :something, :short]
      #   cols[1].__name  #=> :y
      #   cols[1].__stack #=> [:a, :b, :c, :whatever, :something, :short]
      #   cols[2].__name  #=> :z
      #   cols[2].__stack #=> [:a, :b, :c, :whatever, :something, :short]
      #   
      # Also, this allows method chaining to build up a relevant stack:
      # 
      #   col = FauxColumn.new :a, :b
      #   col.__name  #=> :b
      #   col.__stack #=> [:a]
      # 
      #   col.one.two.three #=> col
      #   col.__name  #=> :three
      #   col.__stack #=> [:a, :b, :one, :two]
      #
      def method_missing(method, *args)
        @stack << @name
        @name   = method
        
        if (args.empty?)
          self
        elsif (args.length == 1)
          method_missing(args.first)
        else
          args.collect { |arg|
            FauxColumn.new(@stack + [@name, arg])
          }
        end
      end
    end
  end
end