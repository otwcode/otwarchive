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

  describe 'Cocreators' do
    before(:each) do
      @creator = FactoryGirl.create(:user)
      User.current_user = @creator
      @co_creator = FactoryGirl.create(:user)
      @no_co_creator = FactoryGirl.create(:user)
      @co_creator.preference.allow_cocreator = true
      @co_creator.preference.save
    end
    let(:valid_work) {build(:work, authors: [@creator.pseuds.first])}


    it 'checks that normal co creator can co create' do
      work = valid_work
      authors = [@creator.pseuds.first, @co_creator.pseuds.first]
      chapter = Chapter.new(work: work, content: "Cool story, bro!", authors: authors)
      expect{ chapter.save! }.to_not raise_error
      expect( chapter.authors ).to match_array(authors)
      expect(work.authors).to match_array([@creator.pseuds.first])
      expect(chapter.authors).to match_array(authors)
    end

    it 'checks a creator can not add a standard user' do
      work = valid_work
      authors = [@creator.pseuds.first, @no_co_creator.pseuds.first]
      chapter =  Chapter.new(work: work, content: "Cool story, bro!", authors: authors)
      expect { chapter.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Trying to add a invalid co creator')
    end
  end

end
