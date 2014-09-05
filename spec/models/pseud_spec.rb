require 'spec_helper'

describe Pseud do 

  it "has a valid factory" do
    build(:pseud).should be_valid
  end

  it "is invalid if there are special characters" do
      @pseud = build(:pseud, name: '*pseud*')
      @pseud.should be_invalid
  end

  # TODO: add more tests
  
end