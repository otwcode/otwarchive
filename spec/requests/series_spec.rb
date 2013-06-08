require 'spec_helper'

describe "Series" do
  subject { page }

  context "that have been deleted" do
    it "should redirect and give a proper error message" do
      visit "/series/12345/"
      should have_content("We're sorry, but that series does not exist.")
    end
  end
end