require 'spec_helper'

describe Work do

  before(:each) do
    @author = Factory.create(:user)
    @fandom1 = Factory.create(:fandom)
    @chapter1 = Chapter.create(:content => "Awesome content")

    @work = Work.new(:title => "Title")
    @work.fandoms << @fandom1
    @work.authors = [@author.pseuds.first]
    @work.chapters << @chapter1
    
  end

  it "should save minimalistic work" do
    @work.save.should == true
  end

  it "should not save work without title" do
    @work.title = nil
    @work.save.should == false
    @work.errors[:title].should_not be_empty

    @work.title = ""
    @work.save.should == false
    @work.errors[:title].should_not be_empty
  end
  
end
