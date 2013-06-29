require 'spec_helper'

describe Collection do
  
  before do
    @collection = FactoryGirl.create(:collection)
  end

  describe "collections with challenges" do
    [GiftExchange, PromptMeme].each do |challenge_klass|

      describe "of type #{challenge_klass.name}" do        
        before do
          @collection.challenge = challenge_klass.new
          @collection.save
          @challenge = @collection.challenge
        end
      
        it "should correctly identify the collection challenge type" do
          @collection.gift_exchange?.should eq(@challenge.is_a?(GiftExchange))
          @collection.prompt_meme?.should eq(@challenge.is_a?(PromptMeme))
        end

        describe "with open signup" do
          before do
            @challenge.signup_open = true
          end        

          describe "and close date in the future" do
            before do
              @challenge.signups_close_at = Time.now + 3.days
              @challenge.save
            end
                  
            it "should be listed as open" do
              Collection.signup_open(@challenge.class.name).should include(@collection)
            end
          end
        
          describe "and close date in the past" do
            before do
              @challenge.signups_close_at = 3.days.ago
              @challenge.save
            end
          
            it "should not be listed as open" do
              Collection.signup_open(@challenge.class.name).should_not include(@collection)
            end
          
          end
        end
      
        describe "with closed signup" do
          before do
            @challenge.signup_open = false
            @challenge.save
          end
        
          it "should not be listed as open" do
            Collection.signup_open(@challenge.class.name).should_not include(@collection)
          end
        end
      end

    end # challenges type loop
  end
end
