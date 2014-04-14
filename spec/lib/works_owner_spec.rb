require 'spec_helper'

describe WorksOwner do
  
  before do
    @tag = Tag.new
    @tag.id = 666
    @time = "2013-09-27 19:14:18 -0400".to_datetime
    @time_string = @time.to_i.to_s
    Delorean.time_travel_to @time
    @tag.update_works_index_timestamp!
    Delorean.back_to_the_present
  end
  
  describe "works_index_timestamp" do
    it "should retrieve the owner's timestamp" do
      @tag.works_index_timestamp.should == @time_string
    end
  end
  
  describe "works_index_cache_key" do
    it "should return the full cache key" do
      @tag.works_index_cache_key.should == "works_index_for_tag_666_#{@time_string}"
    end
    
    it "should accept a tag argument and return the tag's timestamp" do
      collection = Collection.new
      collection.id = 42
      collection.works_index_cache_key(@tag).should == "works_index_for_collection_42_tag_666_#{@time_string}"
    end
  end
  
  describe "update_works_index_timestamp!" do
    it "should update the timestamp for the owner" do
      @tag.update_works_index_timestamp!
      @tag.works_index_timestamp.should_not == @time_string
    end
  end
  
  describe "index_cache_key" do
    
    shared_examples_for "an owner" do
      it "should change after a work is updated" do
        @work.save
        @original_cache_key.should_not eq(@owner.works_index_cache_key)
      end
      
      xit "should change after a work is deleted" do
        @work.destroy
        @original_cache_key.should_not eq(@owner.works_index_cache_key)
      end      
    end
    
    shared_examples_for "an owner tag" do
      it "should change after a new work is created" do
        new_work = FactoryGirl.create(:work, :fandom_string => @owner.name, :posted => true)
        @original_cache_key.should_not eq(@owner.works_index_cache_key)
      end
    end  
    
    shared_examples_for "an owner collection" do
      it "should change after a new work is created" do
        new_work = FactoryGirl.create(:work, :collection_names => @owner.name, :posted => true)
        @owner.collection_items.each {|ci| ci.approve(nil); ci.save}
        @child.collection_items.each {|ci| ci.approve(nil); ci.save} if @child
        @original_cache_key.should_not eq(@owner.works_index_cache_key)
      end
    end  
    
    shared_examples_for "an owner user" do 
      it "should change after a new work is created" do
        author = @owner.is_a?(Pseud) ? @owner : @owner.default_pseud
        new_work = FactoryGirl.create(:work, :authors => [author], :posted => true)
        @original_cache_key.should_not eq(@owner.works_index_cache_key)
      end
      
      it "should change after a work is orphaned" do
        author = @owner.is_a?(Pseud) ? @owner : @owner.default_pseud
        Creatorship.orphan([author], [@work])
        @original_cache_key.should_not eq(@owner.works_index_cache_key)
      end
    end
        
    describe "for a canonical tag" do
      before do
        Delorean.time_travel_to "10 minutes ago"
        @owner = FactoryGirl.create(:fandom, :canonical => true)
        @work = FactoryGirl.create(:work, :fandom_string => @owner.name, :posted => true)
        @original_cache_key = @owner.works_index_cache_key
        Delorean.back_to_the_present
      end
      it_should_behave_like "an owner"
      it_should_behave_like "an owner tag"
      
      describe "with a synonym" do
        before do
          Delorean.time_travel_to "10 minutes ago"
          @syn_tag = FactoryGirl.create(:fandom, :canonical => false)
          @syn_tag.syn_string = @owner.name
          @syn_tag.save
          @work2 = @work
          @work = FactoryGirl.create(:work, :fandom_string => @syn_tag.name, :posted => true)
          @original_cache_key = @owner.works_index_cache_key
          Delorean.back_to_the_present
        end
        it_should_behave_like "an owner"
        it_should_behave_like "an owner tag"
        
        it "should change after a new work is created in the synonym" do
          new_work = FactoryGirl.create(:work, :fandom_string => @syn_tag.name, :posted => true)
          @original_cache_key.should_not eq(@owner.works_index_cache_key)
        end
        
      end
    end
    
    describe "for a collection" do
      before do
        Delorean.time_travel_to "10 minutes ago"
        @owner = FactoryGirl.create(:collection)
        @work = FactoryGirl.create(:work, :collection_names => @owner.name, :posted => true)
      
        # we have to approve the collection items before we get a change in
        # the cache key, since it uses approved works
        @owner.collection_items.each {|ci| ci.approve(nil); ci.save}
      
        @original_cache_key = @owner.works_index_cache_key
        Delorean.back_to_the_present
      end
      it_should_behave_like "an owner"
      it_should_behave_like "an owner collection"
            
      describe "with a child" do
        before do
          Delorean.time_travel_to "10 minutes ago"
          # Stub out User.current_user to get past the collection needing to be owned by same person as parent
          User.stub!(:current_user).and_return(@owner.owners.first.user)
          @child = FactoryGirl.create(:collection, :parent_name => @owner.name)
          # reload the parent collection
          @owner.reload
          @work1 = @work
          @work = FactoryGirl.create(:work, :collection_names => @child.name, :posted => true)
          @child.collection_items.each {|ci| ci.approve(nil); ci.save}
          @original_cache_key = @owner.works_index_cache_key
          Delorean.back_to_the_present
        end
        it_should_behave_like "an owner"
        it_should_behave_like "an owner collection"
      end
      
      describe "with a subtag" do
        before do
          @fandom = FactoryGirl.create(:fandom)
          @work.fandom_string = @fandom.name
          @work.save
          @original_cache_key = @owner.works_index_cache_key(@fandom)
          @original_cache_key_without_subtag = @owner.works_index_cache_key
        end
        
        it "should have a different key than without the subtag" do
          @original_cache_key.should_not eq(@original_cache_key_without_subtag)
        end
        
        describe "when a new work is added with that tag" do
          before do
            Delorean.time_travel_to "1 second from now"
            @work2 = FactoryGirl.create(:work, :fandom_string => @fandom.name, :collection_names => @owner.name, :posted => true)
            @owner.collection_items.each {|ci| ci.approve(nil); ci.save}
            Delorean.back_to_the_present
          end
          
          it "should update both the cache keys" do
            @original_cache_key_without_subtag.should_not eq(@owner.works_index_cache_key)
            @original_cache_key.should_not eq(@owner.works_index_cache_key(@fandom))
          end
        end            
        
        describe "when a new work is added without that tag" do
          before do
            @fandom2 = FactoryGirl.create(:fandom)
            Delorean.time_travel_to "1 second from now"
            @work2 = FactoryGirl.create(:work, :fandom_string => @fandom2.name, :collection_names => @owner.name, :posted => true)
            @owner.collection_items.each {|ci| ci.approve(nil); ci.save}
            Delorean.back_to_the_present
          end
          
          it "should update the main cache key without the tag" do
            @original_cache_key_without_subtag.should_not eq(@owner.works_index_cache_key)
          end
        
          it "should not update the cache key with the tag" do
            @owner.works_index_cache_key(@fandom).should eq(@original_cache_key)
          end
        end 
        
      end
      
    end
  
    describe "for a user" do
      before do
        @owner = FactoryGirl.create(:user)
        @work = FactoryGirl.create(:work, :authors => [@owner.default_pseud], :posted => true)        
      end
      it_should_behave_like "an owner"
      it_should_behave_like "an owner user"
    end
    
    describe "for a pseud" do
      before do
        user = FactoryGirl.create(:user)
        @owner = FactoryGirl.create(:pseud, :user => user)
        @work = FactoryGirl.create(:work, :authors => [@owner], :posted => true)
      end
      it_should_behave_like "an owner"
      it_should_behave_like "an owner user"
    end
    
  end
  

end
