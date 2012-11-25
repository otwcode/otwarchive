require 'spec_helper'

describe ChallengeAssignment do

  describe "a challenge assignment" do
    before do      
      @assignment = Factory.create(:challenge_assignment)
      @collection = @assignment.collection
    end

    it "should save" do
      @assignment.save.should be_true
    end
    
    it "should initially be unposted and unfulfilled and undefaulted" do
      @assignment.posted?.should be_false
      @assignment.fulfilled?.should be_false
      @assignment.defaulted?.should be_false
    end
    
    describe "when it has an unposted creation" do
      before do
        @author = @assignment.offer_signup.pseud
        @work = Factory.create(:work, :authors => [@author], :posted => false, :collection_names => @collection.name, :challenge_assignment_ids => [@assignment.id])
        @assignment.reload
      end
      
      it "should not change status" do
        @assignment.posted?.should be_false
        @assignment.fulfilled?.should be_false
        @assignment.defaulted?.should be_false
      end

      describe "that gets posted" do
        before do
          @work.posted = true
          @work.save
          @assignment.reload
        end
        
        it "should be posted and fulfilled and undefaulted" do
          # note: if this collection is moderated then fulfilled shouldn't be true
          # until the item is approved
          @assignment.posted?.should be_true
          @assignment.fulfilled?.should be_true
          @assignment.defaulted?.should be_false
        end
        
        describe "that is destroyed" do
          before do
            @work.destroy
            @assignment.reload
          end
          
          it "should be unposted and unfulfilled again" do
            @assignment.posted?.should be_false
            @assignment.fulfilled?.should be_false
            @assignment.defaulted?.should be_false
          end
        end
        
      end
      
    end
  end

end