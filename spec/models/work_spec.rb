require 'spec_helper'

describe Work do

  describe "save" do

    before(:each) do
      @author = FactoryGirl.create(:user)
      @fandom1 = FactoryGirl.create(:fandom)
      @chapter1 = FactoryGirl.create(:chapter)
      
      @work = Work.new(:title => "Title")
      @work.fandoms << @fandom1
      @work.authors = [@author.pseuds.first]
      @work.chapters << @chapter1
      
    end
    
    it "should save minimalistic work" do
      @work.save.should be_true
    end
    
    it "should not save work without title" do
      @work.title = nil
      @work.save.should be_false
      @work.errors[:title].should_not be_empty
      
      @work.title = ""
      @work.save.should be_false
      @work.errors[:title].should_not be_empty
    end
    
  end
    
end
