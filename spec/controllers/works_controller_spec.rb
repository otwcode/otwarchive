require 'spec_helper'

describe WorksController do
  include LoginMacros

  describe "index" do
    before do
      @fandom = FactoryGirl.create(:fandom)
      @work = FactoryGirl.create(:work, :posted => true, :fandom_string => @fandom.name)
    end
    
    it "should return the work" do
      get :index
      assigns(:works).should include(@work)
    end
    
    describe "without caching" do
      before do
        controller.stub!(:use_caching?).and_return(false)
      end
      
      it "should return the result with different works the second time" do
        get :index
        assigns(:works).should include(@work)
        work2 = FactoryGirl.create(:work, :posted => true)
        get :index
        assigns(:works).should include(work2)
      end
    end
    
    describe "with caching" do
      before do
        controller.stub!(:use_caching?).and_return(true)
      end
      
      it "should return the same result the second time when a new work is created within the expiration time" do
        get :index
        assigns(:works).should include(@work)
        work2 = FactoryGirl.create(:work, :posted => true)
        work2.index.refresh
        get :index
        assigns(:works).should_not include(work2) 
      end
      
      describe "with an owner tag" do
        before do
          @fandom2 = FactoryGirl.create(:fandom)
          @work2 = FactoryGirl.create(:work, :posted => true, :fandom_string => @fandom2.name)
          @work2.index.refresh
        end
        
        it "should only get works under that tag" do
          get :index, :tag_id => @fandom.name
          assigns(:works).items.should include(@work)
          assigns(:works).items.should_not include(@work2)
        end

        it "should show different results on second page" do
          get :index, :tag_id => @fandom.name, :page => 2
          assigns(:works).items.should_not include(@work)
        end
      
        describe "with restricted works" do
          before do
            @work2 = FactoryGirl.create(:work, :posted => true, :fandom_string => @fandom.name, :restricted => true)
            @work2.index.refresh
          end
        
          it "should not show restricted works to guests" do
            get :index, :tag_id => @fandom.name
            assigns(:works).items.should include(@work)
            assigns(:works).items.should_not include(@work2)
          end

          it "should show restricted works to logged-in users" do
            fake_login            
            get :index, :tag_id => @fandom.name
            assigns(:works).items.should =~ [@work, @work2]
          end
        end
        
      end
    end

  end
  
end