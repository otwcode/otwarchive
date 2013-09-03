require 'spec_helper'

describe Work do
  
  # see lib/collectible_spec for collection-related tests

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
    
    it "should send an email when added to collection" do
      collection = Collection.new
      collection.collection_preference = CollectionPreference.new
      @work.add_to_collection(collection)
      
    end
  end
  
  describe "new recipients virtual attribute" do
    
    before(:each) do
      @author = FactoryGirl.create(:user)
      @recipient1 = FactoryGirl.create(:user)
      @recipient2 = FactoryGirl.create(:user)
      @recipient3 = FactoryGirl.create(:user)
      
      @fandom1 = FactoryGirl.create(:fandom)
      @chapter1 = FactoryGirl.create(:chapter)
      
      @work = Work.new(:title => "Title")
      @work.fandoms << @fandom1
      @work.authors = [@author.pseuds.first]
      @work.recipients = @recipient1.pseuds.first.name + "," + @recipient2.pseuds.first.name
      @work.chapters << @chapter1
    end
    
    it "should be the same as recipients when they are first added" do
      @work.new_recipients.should eq(@work.recipients)
    end
    
    it "should only contain the new recipients when more are added" do
      @work.recipients += "," + @recipient3.pseuds.first.name
      @work.new_recipients.should eq(@recipient3.pseuds.first.name)
    end
    
    it "should only contain the new recipient if replacing the previous recipient" do
      @work.recipients = @recipient3.pseuds.first.name
      @work.new_recipients.should eq(@recipient3.pseuds.first.name)
    end
    
    it "should be empty if one or more of the original recipients are removed" do
      @work.recipients = @recipient2.pseuds.first.name
      @work.new_recipients.should be_empty
    end
    
  end 
    
end
