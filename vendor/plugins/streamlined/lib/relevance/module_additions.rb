module Relevance; end
module Relevance::ModuleAdditions
  # Provides an alternative to Rails' delegate method. We needed two things
  # that Rails did not do: delegate from one method name to another, and 
  # provide a default value if the delegate object is nil. :to is required
  # :method is optional (default is the method name being called)
  # :default is optional (default is to blow up if the delegate is nil)
  # 
  # Usage
  #   class Foo < ActiveRecord::Base
  #     delegates :hello, :goodbye, :to => :greeter, :method=>:salutation, :default=>'Cheers'
  #   end
  #
  def delegate_targets
    @delegate_targets ||= []
  end                 
  
  def delegates(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a :to option"
    end
    delegate_targets << to
    method_to, default, visibility = options[:method], options[:default], options[:visibility]
    if options.has_key? :default
      methods.each do |method_from|
        method = method_to ? method_to : method_from
        # TODO: how to pass a block?
        define_method(method_from) do |*args|
          self.send(to) ? self.send(to).send(method,*args) : default
        end
      end
    else
      methods.each do |method_from|
        method = method_to ? method_to : method_from
        module_eval(<<-EOS, "(__DELEGATION__)", 1)
          def #{method_from}(*args, &block)
            #{to}.__send__(#{method.inspect}, *args, &block)
          end
        EOS
      end
    end
    if visibility
      self.send(visibility, *methods)
    end
  end
  # Declare an attribute with an initial default 
  #
  # To give attribute :foo the initial value :bar
  # attr_with_default :foo, :bar
  #
  # To give attribute :foo a dynamic default value, evaluated
  # in scope of self
  # attr_with_default(:foo) {something_interesting}
  #
  def attr_with_default(sym, *rest, &proc)
    default = rest[0] unless rest.empty?
    raise 'default value or proc required' unless (default || proc)
    if default
      module_eval "def #{sym}; @#{sym}||=#{default}; end"
    end
    if proc
      define_method(sym) do
        self.instance_eval(&proc)
      end
    end
    module_eval <<-END
def #{sym}=(value)
  class << self ; attr_reader :#{sym} ; end
  @#{sym} = value
end
END
  end
end

Module.class_eval {include Relevance::ModuleAdditions}
