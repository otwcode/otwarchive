require 'flexmock'
class FlexMock
  class StubProxy
    # new_instances is a short cut method for overriding the behavior of any 
    # instance created via a stubbed class object.
    def new_instances(*allocators, &block)
      @allocators = [:allocate, :new] if allocators.empty?
      fail ArgumentError, "any_instance requires a Class to stub" unless Class === @obj
      allocators.each do |m|
        self.should_receive(m).and_return { |*args|
          new_obj = invoke_original(m, args)
          mock = mock_container.flexstub(new_obj)
          block.call(mock)
          new_obj
        }
      end
      nil
    end

    # Invoke the original definition of method on the object supported by 
    # the stub.
    def invoke_original(method, args)
      method_proc = @method_definitions[method]
      block = nil
      if Proc === args.last
        block = args.last
        args = args[0...-1]
      end
      method_proc.call(*args, &block)
    end
    private :invoke_original

  end
end