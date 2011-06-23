require 'spec_helper'

describe Tag do

  it "should create a new fandom" do
    tag = Tag.create(:name => "fandom1",
                        :type => "fandom",
                        :canonical => true)
    tag.name.should == "fandom1"
  end

end