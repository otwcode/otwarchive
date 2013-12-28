require 'spec_helper'

def update_collection_setting(collection, setting, value)
  collection.collection_preference.send("#{setting}=", value)
  collection.collection_preference.save
end

describe Collectible do
  
  # TO-DO: update this to test the code for all types of collectibles, 
  # bookmarks, works, etc
  
  it "should not be put into a nonexistent collection" do
    fake_name = "blah_blah_blah_not_an_existing_name"
    work = FactoryGirl.create(:work)
    work.collection_names = fake_name
    work.errors[:base].first.should match("find") # use a very basic part of the error message
    work.errors[:base].first.should match(fake_name)
    work.save.should be_true
    work.reload
    work.collection_names.should_not include(fake_name)
  end  
  
  context "being posted to a collection", focus: true do
    let(:collection) { FactoryGirl.create(:collection) }
    # build but don't save so we can change the collection settings
    let(:work) { FactoryGirl.build(:work, :collection_names => collection.name) }
    subject { work }
    
    describe "once added" do
      before do
        work.save
      end
    
      it "should be in that collection" do
        work.save
        work.collections.should include(collection)
        collection.works.should include(work)
      end
    
      it "should be removable" do
        # collection_names= exercises collections_to_(add/remove) methods
        work.collection_names = ""
        work.save
        work.collections.should_not include(collection)
        collection.works.should_not include(work)
      end
    end

    %w(unrevealed anonymous).each do |state|
      describe "which is #{state}" do
        before do
          # set the state of the collection and then save to put the work into the collection
          update_collection_setting(collection, state, true)
          work.save!
        end
      
        it "should be #{state}" do
          work.send("in_#{state == 'anonymous' ? 'anon' : state}_collection").should be_true
        end
      
        describe "and when the collection is no longer #{state}" do
          before do
            collection.collection_preference.send("#{state}=",false)
            collection.collection_preference.save
            work.reload
          end
      
          it "should not be #{state}" do
            collection.send("#{state}?").should_not be_true          
            work.send("in_#{state == 'anonymous' ? 'anon' : state}_collection").should_not be_true
          end
        end
      
        describe "when the work is removed from the collection" do
          before do
            work.collection_names = ""
            work.save
            work.reload
          end
      
          it "should not be #{state}" do
            work.send("in_#{state == 'anonymous' ? 'anon' : state}_collection").should_not be_true
          end
        end
        describe "when the work's collection item is individually changed" do
          before do
            ci = work.collection_items.first
            ci.send("#{state}=", false)
            ci.save
            work.reload
          end
          
          it "should no longer be #{state}" do
            work.send("in_#{state == 'anonymous' ? 'anon' : state}_collection").should_not be_true
          end
        end
      end
    end
  end

end
