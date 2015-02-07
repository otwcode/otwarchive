require 'spec_helper'

describe Pseud do

  it "has a valid factory" do
    expect(build(:pseud)).to be_valid
  end

  it "is invalid without a name" do
    expect(build(:pseud, name: nil)).to be_invalid
  end

  it "is invalid if there are special characters" do
      expect(build(:pseud, name: '*pseud*')).to be_invalid
  end

  # TODO: add more tests

end