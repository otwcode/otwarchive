require 'spec_helper'
require 'ruby-debug'

describe TagSetNomination do

  describe "save" do
    
    before(:each) do
      @tag_set_nomination = Factory.create(:tag_set_nomination)
    end
    
    it "should save a basic tag set nomination" do
      @tag_set_nomination.save.should be_true
    end
    
  end
  
end
