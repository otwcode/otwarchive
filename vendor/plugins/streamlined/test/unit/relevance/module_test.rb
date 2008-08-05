require File.dirname(__FILE__) + '/../../test_helper'


describe "Relevance::ModuleExtensions" do
  class TestMe
    def callme(*args); "foo"; end
  end
  
  it "wrap method" do
    @inst = TestMe.new
    assert_equal "foo", @inst.callme
    assert_equal "foo", @inst.callme(1)
    @inst.class.wrap_method :callme do |old_meth, *args|
      if args && args.size > 0
        args.size
      else
        old_meth.call
      end
    end
    assert_equal "foo", @inst.callme
    assert_equal 1, @inst.callme(1)
  end

end
