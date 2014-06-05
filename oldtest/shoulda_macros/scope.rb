class Test::Unit::TestCase
  # Ensures that the model has a method named scope_name that returns a NamedScope object with the
  # proxy options set to the options you supply.  scope_name can be either a symbol, or a method
  # call which will be evaled against the model.  The eval'd method call has access to all the same
  # instance variables that a should statement would.
  #
  # Options: Any of the options that the named scope would pass on to find.
  #
  # Example:
  #
  #   should_have_scope :visible, :conditions => {:visible => true}
  #
  # Passes for
  #
  #   scope :visible, :conditions => {:visible => true}
  #
  # Or for
  #
  #   def self.visible
  #     scoped(:conditions => {:visible => true})
  #   end
  #
  # You can test lambdas or methods that return ActiveRecord#scoped calls:
  #
  #   should_have_scope 'recent(5)', :limit => 5
  #   should_have_scope 'recent(1)', :limit => 1
  #
  # Passes for
  #   scope :recent, lambda {|c| {:limit => c}}
  #
  # Or for
  #
  #   def self.recent(c)
  #     scoped(:limit => c)
  #   end
  #
  def self.should_have_scope(scope_call, *args)
    klass = described_type
    scope_opts = args.extract_options!
    scope_call = scope_call.to_s
 
    context scope_call do
      setup do
        @scope = eval("#{klass}.#{scope_call}")
      end
 
      should "return a scope object" do
        assert_equal ::ActiveRecord::NamedScope::Scope, @scope.class
      end
 
      unless scope_opts.empty?
        should "scope itself to #{scope_opts.inspect}" do
          assert_equal scope_opts, @scope.proxy_options
        end
      end
    end
  end
end
