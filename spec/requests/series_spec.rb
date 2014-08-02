require 'spec_helper'

describe "Series" do
  subject { page }

  context "that have been deleted" do
    it "should respond with a 404" do
      visit "/series/12345/"
      response.response_code.should == 404
    end
  end
end
