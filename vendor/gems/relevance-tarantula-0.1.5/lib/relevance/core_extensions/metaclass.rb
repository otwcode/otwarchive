# This is a direct copy of the facets library metaclass stuff.
# used by Tarantula pulling in all of Facets doesn't make sense here.

# From lib/core/facets/metaid.rb
module Kernel
  def meta_alias(*args)
    meta_class do
      alias_method(*args)
    end
  end

  def meta_eval(str=nil, &blk)
    if str
      meta_class.instance_eval(str)
    else
      meta_class.instance_eval(&blk)
    end
  end

  def meta_def( name, &block )
    meta_class do
      define_method( name, &block )
    end
  end

  def meta_class(&block)
    if block_given?
      (class << self; self; end).class_eval(&block)
    else
      (class << self; self; end)
    end
  end

  alias_method :metaclass, :meta_class

  def eigenclass
    (class << self; self; end)
  end
end

class Module
  def class_def name, &blk
    class_eval { define_method name, &blk }
  end

  protected :attr
  protected :attr_reader
  protected :attr_writer
  protected :attr_accessor
  protected :remove_method
  protected :undef_method
end

# From /lib/more/facets/kernel/meta.rb
module Kernel
  def meta
    @_meta_functor ||= Functor.new do |op,*args|
      (class << self; self; end).send(op,*args)
    end
  end
end

# From /lib/core/facets/functor.rb
class Functor
  private(*instance_methods.select { |m| m !~ /(^__|^binding$)/ })

  def initialize(&function)
    @function = function
  end

  def to_proc
    @function
  end

  def method_missing(op, *args, &blk)
    @function.call(op, *args, &blk)
  end
end
