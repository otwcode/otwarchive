require File.dirname(__FILE__) + "/../spec_helper"

module FixtureReplacementController
  describe DelayedEvaluationProc do
    it "should be a kind of proc" do
      DelayedEvaluationProc.superclass.should == Proc
      (DelayedEvaluationProc.new {}).should be_a_kind_of(Proc)
    end
  end  
end
