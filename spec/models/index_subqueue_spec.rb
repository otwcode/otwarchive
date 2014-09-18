require 'spec_helper'

describe IndexSubqueue do

  let(:subqueue) { IndexSubqueue.new("index:work:main:1234567:0") }

  it "should have ids added to it" do
    subqueue.add_ids([1,2,3,4])
    subqueue.ids.should == %w(1 2 3 4)
  end

  it "should get its target class from the name" do
    subqueue.klass.should == Work
  end

  it "should get its label from the name" do
    subqueue.label.should == "main"
  end

end