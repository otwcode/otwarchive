# -*- coding: utf-8 -*-
require 'spec_helper'

describe Chapter do

  describe "save" do

    before(:each) do
      @work = FactoryGirl.create(:work)
      @chapter = Chapter.new(:work => @work, :content => "Cool story, bro!")
    end
    
    it "should save minimalistic chapter" do
      @chapter.save.should be_true
    end
    
  end

  describe "set_word_count" do
    let(:chapter) { chapter = FactoryGirl.create(:chapter) }

    it "should count plain words delimited with spaces" do
      chapter.content = "one two three four"
      chapter.set_word_count
      chapter.word_count.should == 4
    end

    it "should count plain words delimited with linebreaks" do
      chapter.content = "one\ntwo\nthree\nfour"
      chapter.set_word_count
      chapter.word_count.should == 4
    end

    it "should count hyphenated words as one" do
      chapter.content = "arm-rest is hyphenated"
      chapter.set_word_count
      chapter.word_count.should == 3
    end

    it "should count contractions as one" do
      chapter.content = "don't do that"
      chapter.set_word_count
      chapter.word_count.should == 3
    end

    it "should not count lone html tags" do
      chapter.content = "<p align='center'> one </p> <i> two </i> <s> three </s>"
      chapter.set_word_count
      chapter.word_count.should == 3
    end

    it "should recognise html tags as word delimiter" do
      chapter.content = "<p>one</p>two<br/>three"
      chapter.set_word_count
      chapter.word_count.should == 3
    end

    it "should not count empty html tags as words" do
      chapter.content = "<p>one</p> <p>  </p> <p>two</p>"
      chapter.set_word_count
      chapter.word_count.should == 2
    end

    %w(* ~ !? - ~* ~!).each do |char|
      it "should not count a line of #{char} as word" do
        chapter.content = "<p>one</p> <p>#{char*10}</p> <p>two</p>"
        chapter.set_word_count
        chapter.word_count.should == 2
      end
    end

    it "should count words with special charcters correctly" do
      chapter.content = "zwölf naïve fiancés"
      chapter.set_word_count
      chapter.word_count.should == 3
    end

    %w(— -- , /).each do |char|
      it "should recognise #{char} as word delimiter" do
        chapter.content = "one#{char}two#{char}three"
        chapter.set_word_count
        chapter.word_count.should == 3
      end
    end
    
    %w(— -- - ! ? . , / " ' ).each do |char| #"
      it "should not count lone #{char} as words" do
        chapter.content = "one #{char} two #{char} three"
        chapter.set_word_count
        chapter.word_count.should == 3
      end
    end

    it "should handle common punctuation" do
      chapter.content = "\Hey Bob,\" said Alice, 'Yay?!?'"
      chapter.set_word_count
      chapter.word_count.should == 5
    end

  end
    
end
