# -*- coding: utf-8 -*-
require 'spec_helper'
require 'nokogiri'

describe HtmlCleaner do
  include HtmlCleaner
  
  describe "fix_bad_characters" do

    it "should not touch normal text" do
      fix_bad_characters("normal text").should == "normal text"
    end

    it "should not touch normal text with valid unicode chars" do
      fix_bad_characters("nörmäl’téxt").should == "nörmäl’téxt"
    end

    it "should remove invalid unicode chars" do
      bad_string = [65, 150, 65].pack("C*")  # => "A\226A"
      fix_bad_characters(bad_string).should == "AA"
    end

    it "should escape <3" do
      fix_bad_characters("normal <3 text").should == "normal &lt;3 text"
    end

    it "should convert \r\n to \n" do
      fix_bad_characters("normal\r\ntext").should == "normal\ntext"
    end

    it "should remove the spacer" do
      fix_bad_characters("A____spacer____A").should == "AA"
    end

    it "should remove unicode chars in the 'other, format' category" do
      fix_bad_characters("A\xE2\x81\xA0A").should == "AA"
    end
  end

  describe "add_paragraphs_to_text" do

    it "should keep existing p tags as is" do
      result = add_paragraphs_to_text("<p>some</p><p>text</p>")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]").children.to_s.strip.should == "text" 
    end

    it "should keep existing p tags as is" do
      result = add_paragraphs_to_text("<p>some</p>\n\n<p>text</p>")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]").children.to_s.strip.should == "text" 
    end


    it "should enclose plain text in p tags" do
      result = add_paragraphs_to_text("some text")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some text" 
    end

    it "should convert single linebreak to br" do
      result = add_paragraphs_to_text("some\ntext")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some<br/>text" 
    end

    it "should convert double linebreaks to paragraph break" do
      result = add_paragraphs_to_text("some\n\ntext")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]").children.to_s.strip.should == "text" 
    end

    it "should convert triple linebreaks into blank line" do
      result = add_paragraphs_to_text("some\n\n\ntext")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]").children.to_s.strip.should == "&#xA0;" 
      doc.xpath("./p[3]").children.to_s.strip.should == "text" 
    end
  
    it "should convert double br tags into paragraph break" do
      result = add_paragraphs_to_text("some<br/><br/>text")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]").children.to_s.strip.should == "text" 
    end

    %w(b big cite code del em i s small strike strong sub sup tt u).each do |tag|

      it "should handle #{tag} inline tags spanning double line breaks" do
        result = add_paragraphs_to_text("<#{tag}>some\n\ntext</#{tag}>")
        doc = Nokogiri::XML.fragment(result)
        doc.xpath("./p[1]/#{tag}").children.to_s.strip.should == "some" 
        doc.xpath("./p[2]/#{tag}").children.to_s.strip.should == "text"
      end
    end

    %w(blockquote center div).each do |tag|
      it "should handle #{tag} block tag spanning double line breaks" do
        pending "HtmlCleaner needs fixing" unless tag=="div"
        result = add_paragraphs_to_text("<#{tag}>some\n\ntext</#{tag}>")
        doc = Nokogiri::XML.fragment(result)
        doc.xpath("./#{tag}/p[1]").children.to_s.strip.should == "some" 
        doc.xpath("./#{tag}/p[2]").children.to_s.strip.should == "text" 
      end
    end

  end  

end
