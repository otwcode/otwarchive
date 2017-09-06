# -*- coding: utf-8 -*-
require 'spec_helper'

describe Chapter do

  it "has a valid factory" do
    expect(build(:chapter)).to be_valid
  end

  it "is invalid without content" do
    expect(build(:chapter, content: nil)).to be_invalid
  end

  it "is unposted by default" do
    chapter = create(:chapter)
    chapter.posted.should == false
  end

  describe "save" do

    before(:each) do
      @work = FactoryGirl.create(:work)
      @chapter = Chapter.new(work: @work, content: "Cool story, bro!")
    end

    it "should save minimalistic chapter" do
      expect(@chapter.save).to be_truthy
    end

  end

end
