# -*- coding: utf-8 -*-

require 'word_counter'

describe WordCounter do
 let(:word_counter) { WordCounter.new("") }

  it "should count plain words delimited with spaces" do
    word_counter.text = "one two three four"
    word_counter.count.should == 4
  end

  it "should count plain words delimited with linebreaks" do
    word_counter.text = "one\ntwo\nthree\nfour"
    word_counter.count.should == 4
  end

  it "should count hyphenated words as one" do
    word_counter.text = "arm-rest is hyphenated"
    word_counter.count.should == 3
  end

  it "should count contractions as one" do
    word_counter.text = "don't do that"
    word_counter.count.should == 3
  end

  it "should not count lone html tags" do
    word_counter.text = "<p align='center'> one </p> <i> two </i> <s> three </s>"
    word_counter.count.should == 3
  end

  it "should recognise html tags as word delimiter" do
    word_counter.text = "<p>one</p>two<br/>three"
    word_counter.count.should == 3
  end

  it "should not count empty html tags as words" do
    word_counter.text = "<p>one</p> <p>  </p> <p>two</p>"
    word_counter.count.should == 2
  end

  %w(* ~ !? - ~* ~!).each do |char|
    it "should not count a line of #{char} as word" do
      word_counter.text = "<p>one</p> <p>#{char*10}</p> <p>two</p>"
      word_counter.count.should == 2
    end
  end

  it "should count words with special charcters correctly" do
    word_counter.text = "zwölf naïve fiancés"
    word_counter.count.should == 3
  end

  %w(— -- , /).each do |char|
    it "should recognise #{char} as word delimiter" do
      word_counter.text = "one#{char}two#{char}three"
      word_counter.count.should == 3
    end
  end

  %w(— -- - ! ? . , / " ' ).each do |char| #"
    it "should not count lone #{char} as words" do
      word_counter.text = "one #{char} two #{char} three"
      word_counter.count.should == 3
    end
  end

  it "should handle common punctuation" do
    word_counter.text = "\Hey Bob,\" said Alice, 'Yay?!?'"
    word_counter.count.should == 5
  end  
   
end
