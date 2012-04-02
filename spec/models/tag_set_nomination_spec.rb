require 'spec_helper'
require 'ruby-debug'

describe TagSetNomination do

  describe "save" do
    
    before(:each) do
      @user = FactoryGirl.create(:user)

      @owned_tag_set = OwnedTagSet.new(:title => "Testing")
      @owned_tag_set.build_tag_set
      @owned_tag_set.add_owner(@user.default_pseud)
      @owned_tag_set.nominated = true
      @owned_tag_set.save      
      
      @tag_set_nomination = TagSetNomination.new(:owned_tag_set_id => @owned_tag_set.id, :pseud_id => @user.default_pseud.id)
    end
    
    it "should save a basic tag set nomination" do
      @tag_set_nomination.save.should be_true
    end
    
  end
  
end
