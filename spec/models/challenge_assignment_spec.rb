require 'spec_helper'

describe ChallengeAssignment do

  describe "a challenge assignment" do
    before do      
      @assignment = FactoryGirl.create(:challenge_assignment)
      @collection = @assignment.collection
    end

    it "should save" do
      @assignment.save.should be_true
    end
    
    it "should initially be unposted and unfulfilled and undefaulted" do
      @assignment.posted?.should be_false
      @assignment.fulfilled?.should be_false
      @assignment.defaulted?.should be_false
      @collection.assignments.unstarted.should include(@assignment)
      @collection.assignments.unposted.should include(@assignment)
      @collection.assignments.unfulfilled.should include(@assignment)
    end

    it "should be unsent" do
      @collection.assignments.sent.should_not include(@assignment)
    end
    
    describe "after being sent" do
      before do
        @assignment.send_out
      end
      it "should be sent" do
        @collection.assignments.sent.should include(@assignment)
      end
    end      
    
    describe "when it has an unposted creation" do
      before do
        @assignment.send_out
        @author = @assignment.offer_signup.pseud
        @work = FactoryGirl.create(:work, :authors => [@author], :posted => false, :collection_names => @collection.name, :challenge_assignment_ids => [@assignment.id])
        @assignment.reload
      end
      
      it "should be started but not posted fulfilled or defaulted" do
        @assignment.started?.should be_true
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