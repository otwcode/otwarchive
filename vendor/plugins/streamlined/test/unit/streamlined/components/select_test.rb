require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))

include Streamlined::Components

describe "Select component" do
  
  it "should fail fast if there are missing args" do
    lambda{Select.render}.should.raise(ArgumentError)
  end

  it "renders a select tag plus a hidden input field with STREAMLINED_SELECT_NONE" do
    view = ActionView::Base.new
    tags = Select.render(:view => view, :object => "person", :method => "friends") do |s|
      s.choices = ["Joe", "John"]
      s.html_options = {:size => 5, :multiple => true}
    end
    html = root_node "<div>#{tags}</div>"
    assert_select html, "select[id=person_friends][size=5]" do |select|
      assert_select "option[value=Joe]", "Joe"
      assert_select "option[value=John]", "John"
    end                                       
    assert_select html, "input[type=hidden][value=#{STREAMLINED_SELECT_NONE}]"
  end
  
  it "can purge all special select none markers" do
    params = {:foo => "bar", 
               :bar => [STREAMLINED_SELECT_NONE, "1"],
               :bee => {:bar => ["5", STREAMLINED_SELECT_NONE]},
               :quux => ["3"]}
    Select.purge_streamlined_select_none_from_params(params)
    params.should ==
              {:foo => "bar", 
                :bee => {:bar => ["5"]},
                :bar => ["1"],
                :quux => ["3"]}
  end
  
  it "should handle nil or empty hash" do
    Select.purge_streamlined_select_none_from_params(nil).should == nil
    Select.purge_streamlined_select_none_from_params({}).should == {}
  end
end

