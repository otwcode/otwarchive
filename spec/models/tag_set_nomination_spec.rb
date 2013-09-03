require 'spec_helper'

describe TagSetNomination do

  describe "save" do
    
    before(:each) do
      @tag_set_nomination = FactoryGirl.create(:tag_set_nomination)
    end
    
    it "should save a basic tag set nomination" do
      @tag_set_nomination.save.should be_true
    end
    
  end
  
end
