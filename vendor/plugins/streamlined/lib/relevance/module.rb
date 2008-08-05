module Relevance
  module ModuleHelper
    class << self
      def reader_from_options(sym, opts={})
        default = if opts[:default]
          "#{opts[:default].inspect}"  
        elsif opts[:default_method]
          "#{opts[:default_method]}"
        end
        if default
          "defined?(@#{sym}) ? @#{sym} : #{default}"
        else
          "@#{sym}"
        end
      end
      def define_reader_from_options(obj, setter_rhs, sym, opts)
        reader = reader_from_options(sym, opts)
        method_body=<<-END
def #{sym}(*args)    
  case args.length
  when 0
    #{reader}
  else
    self.#{sym} = #{setter_rhs}
    # why is this next line needed?
    self.instance_variable_get("@#{sym}")
  end
end
END
        obj.module_eval(method_body)
      end
      def define_writer_from_options(obj, sym, opts={})
        if writer = opts[:writer]
          obj.send :define_method, "#{sym}=" do |value|
            self.instance_variable_set("@#{sym}", writer[value])
          end
        else
          obj.send :attr_writer, sym
        end
      end
    end
  end
end

module Relevance
  module ModuleExtensions
    def declarative_attribute(setter_rhs, sym, options={})
      Relevance::ModuleHelper.define_reader_from_options(self, setter_rhs, sym, options)
      Relevance::ModuleHelper.define_writer_from_options(self, sym, options)     
    end
    # def declarative_array(sym, options={})
    #   declarative_attribute("args", sym, options)
    # end
    def declarative_scalar(sym, options={})
      declarative_attribute("args.first", sym, options)
    end
    # Creates a new method wrapping the previous of
    # the same name, passing it into the block
    # definition of the new method.
    #
    # This can not be used to wrap methods that take
    # a block.
    #
    #   wrap_method( sym ) { |old_meth, *args| 
    #     old_meth.call
    #     ...
    #   }
    #
    def wrap_method( name, &blk )
      raise ArgumentError, "method does not exist" unless method_defined?( name ) || private_method_defined?(name)
      old = instance_method(name)
      undef_method(name)
      define_method(name) { |*args| blk.call(old.bind(self), *args) }
    end
  end
end

Module.class_eval do
  include Relevance::ModuleExtensions
end

