require 'spec_helper'

describe Pseud do 

  it "has a valid factory" do
    build(:pseud).should be_valid
  end

  it "is invalid without a name" do
    build(:pseud, name: nil).should be_invalid
  end

  it "is invalid if there are special characters" do
      build(:pseud, name: '*pseud*').should be_invalid
  end

  # TODO: add more tests

end