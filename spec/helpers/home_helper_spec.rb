require 'spec_helper'

describe HomeHelper do

  describe "html_to_text" do
    context "for illegal code" do
      it "should strip out offending characters" do
        string = "<br>I see what you\n have done there.</br><p> Do you see what I see?</p>"
        html_to_text(string).should eq "I see what you have done there. Do you see what I see?"
      end
    end
  end
end