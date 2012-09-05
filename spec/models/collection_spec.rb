require 'spec_helper'

describe Collection do

  describe "challenge_types" do
  
    before(:each) do
      @collection = Collection.new
    end
    
    it "should return true if challenge type is Gift Exchange" do
      @collection.challenge_type = "GiftExchange"
      @collection.gift_exchange?.should be_true
    end

    it "should return false if challenge type is not Gift Exchange" do
      @collection.challenge_type = ""
      @collection.gift_exchange?.should be_false
    end
    
    it "should return true if challenge type is Prompt Meme" do
      @collection.challenge_type = "PromptMeme"
      @collection.prompt_meme?.should be_true
    end
    
    it "should return false if challenge type is not Prompt Meme" do
      @collection.challenge_type = ""
      @collection.prompt_meme?.should be_false

    end
       
  end

end
