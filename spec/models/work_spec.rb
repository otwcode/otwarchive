require 'spec_helper'

describe Work do

  before(:each) do
      @fandom1 = Factory.create(:tag)
  end

  it "should create a new work" do
    work = Work.create(:title => "Title",
                                               :author => "Pseud", 
                                               :content => "Some story text that is more than 10 characters",
                                               :fandom => "The 1 Tag",
                                               :warning => "No Archive Warnings Apply")
    work.title.should == "Title"
    work.author.should == "Pseud"
    work.content.should == "Some story text that is more than 10 characters"
    work.warning.should == "No Archive Warnings Apply"
  end

end