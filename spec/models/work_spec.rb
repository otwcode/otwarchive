require 'spec_helper'

describe Work do
  
  context "added to a collection", focus: true do
    let(:collection) { Factory.create(:collection) }
    let(:work) { Factory.build(:work, :collection_names => collection.name) }
    subject { work }
  
    context "which is unrevealed" do
      before(:each) do
        collection.collection_preference.update_attribute(:unrevealed, true)
        work.save!
      end
      
      it { should be_unrevealed }
      
      describe "when the collection is revealed" do
        before(:each) do
          collection.collection_preference.update_attribute(:unrevealed, false)
          work.reload
        end
        
        it { should_not be_unrevealed }
      end
    end
  
    context "which is anonymous" do
      before(:each) do
        collection.collection_preference.update_attribute(:anonymous, true)
        work.save!
      end
      
      it { should be_anonymous }
      
      describe "when the collection stops being anonymous" do
        before(:each) do
          collection.collection_preference.update_attribute(:anonymous, false)
          work.reload
        end
        
        it { should_not be_anonymous }
      end
    end
  
    context "which is not unrevealed" do
      before(:each) do
        collection.collection_preference.update_attribute(:unrevealed, false)
        work.save!
      end
      
      it { should_not be_unrevealed }
      
      it "should become unrevealed when the collection does"
    end
    
    context "which is not anonymous" do
      before(:each) do
        collection.collection_preference.update_attribute(:anonymous, false)
        work.save!
      end
      
      it { should_not be_anonymous }
      
      it "should become anonymous when the collection does"
    end

  end

  describe "save" do

    before(:each) do
      @author = Factory.create(:user)
      @fandom1 = Factory.create(:fandom)
      @chapter1 = Factory.create(:chapter)
      
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
  
  describe "new recipients virtual attribute" do
    
    before(:each) do
      @author = Factory.create(:user)
      @recipient1 = Factory.create(:user)
      @recipient2 = Factory.create(:user)
      @recipient3 = Factory.create(:user)
      
      @fandom1 = Factory.create(:fandom)
      @chapter1 = Factory.create(:chapter)
      
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
