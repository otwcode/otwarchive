require 'spec_helper'

describe CommentsController do

  describe "on restricted works" do
    before do
      @fandom2 = Factory.create(:fandom)
      @work2 = Factory.create(:work, :posted => true, :fandom_string => "Merlin (TV)" )
      @work2.index.refresh
    end

    it "should not allow guest comments on restricted works" do
      visit "/comments/new"
      current_path.should == "/login?restricted_commenting=true"
    end
  end
end
