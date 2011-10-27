# -*- coding: utf-8 -*-
require 'spec_helper'
require 'nokogiri'

describe HtmlCleaner do
  include HtmlCleaner

  describe "TagStack" do
    let(:stack) { TagStack.new }

    describe "inside paragraph?" do
      it "should return false" do
        stack.concat([["div"], ["i"], ["s"]])
        stack.inside_paragraph?.should be_false
      end

      it "should recognise paragraph in combination with i" do
        stack.concat([["div"], ["p", "i"], ["s"]])
        stack.inside_paragraph?.should be_true
      end

      it "should recognise single paragraph" do
        stack.concat([["div"], ["p"], ["s"]])
        stack.inside_paragraph?.should be_true
      end
    end

    describe "open_paragraph_tags" do
      it "should open tags" do
        stack.concat([["div"], ["p", "i"], ["s"]])
        stack.open_paragraph_tags.should == "<p><i><s>"
      end

      it "should ignore text nodes" do
        stack.concat([["div"], ["p", "i"], ["s"], ["text"]])
        stack.open_paragraph_tags.should == "<p><i><s>"
      end
      
      it "should return empty string when not inside paragraph" do
        stack.concat([["div"], ["i"], ["s"]])
        stack.open_paragraph_tags.should == ""
      end

    end

    describe "close_paragraph_tags" do
      it "should close tags" do
        stack.concat([["div"], ["p", "i"], ["s"]])
        stack.close_paragraph_tags.should == "</s></i></p>"
      end

      it "should ignore text nodes" do
        stack.concat([["div"], ["p", "i"], ["s"], ["text"]])
        stack.close_paragraph_tags.should == "</s></i></p>"
      end

      it "should return empty string when not inside paragraph" do
        stack.concat([["div"], ["i"], ["s"]])
        stack.close_paragraph_tags.should == ""
      end
    end
  end
  
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

    it "should not convert linebreaks after p tags" do
      result = add_paragraphs_to_text("<p>A</p>\n<p>B</p>\n\n<p>C</p>\n\n\n")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath(".//p").size.should == 3
      doc.xpath(".//br").should be_empty
    end

    %w(blockquote center dl div h1 h2 h3 h4 h5 h6 ol pre table ul).each do |tag|
      it "should not convert linebreaks after #{tag} tags" do
        result = add_paragraphs_to_text("<#{tag}>A</#{tag}>\n<#{tag}>B</#{tag}>\n\n<#{tag}>C</#{tag}>\n\n\n")
        doc = Nokogiri::XML.fragment(result)
        doc.xpath(".//p").size.should == 0
        doc.xpath(".//br").should be_empty
      end
    end
    
    it "should not convert linebreaks after br tags" do
      result = add_paragraphs_to_text("A<br>B<br>\n\nC<br>\n\n\n")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath(".//p").size.should == 1
      doc.xpath(".//br").size.should == 3
    end    

    it "should not convert linebreaks after hr tags" do
      result = add_paragraphs_to_text("A<hr>B<hr>\n\nC<hr>\n\n\n")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath(".//p").size.should == 0
      doc.xpath(".//br").should be_empty
    end    


    ["ol", "ul"].each do |tag|
      it "should not convert linebreaks inside #{tag} lists" do
        html = """
        <#{tag}>
          <li>A</li>
          <li>B</li>
        </#{tag}>
        """

        result = add_paragraphs_to_text(html)
        doc = Nokogiri::XML.fragment(result)
        doc.xpath("./#{tag}/li[1]").children.to_s.strip.should == "A" 
        doc.xpath("./#{tag}/li[2]").children.to_s.strip.should == "B"
        doc.xpath(".//br").should be_empty
      end
    end

    it "should not convert linebreaks inside tables" do
      html = """
      <table>
        <tr>
          <td>A</td>
          <td>B</td>
        </tr>
        <tr>
          <td>C</td>
          <td>D</td>
        </tr>
      </table> 
      """
      
      result = add_paragraphs_to_text(html)
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./table/tr[1]/td[1]").children.to_s.strip.should == "A" 
      doc.xpath("./table/tr[1]/td[2]").children.to_s.strip.should == "B" 
      doc.xpath("./table/tr[2]/td[1]").children.to_s.strip.should == "C" 
      doc.xpath("./table/tr[2]/td[2]").children.to_s.strip.should == "D" 
      doc.xpath(".//br").should be_empty
    end

    it "should not convert linebreaks inside definition lists" do
      html = """
      <dl>
        <dt>A</dt>
        <dd>aaa</dd>
        <dt>B</dt>
        <dd>bbb</dd>
      </dl> 
      """
      
      result = add_paragraphs_to_text(html)
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./dl/dt[1]").children.to_s.strip.should == "A" 
      doc.xpath("./dl/dd[1]").children.to_s.strip.should == "aaa" 
      doc.xpath("./dl/dt[2]").children.to_s.strip.should == "B" 
      doc.xpath("./dl/dd[2]").children.to_s.strip.should == "bbb" 
      doc.xpath(".//br").should be_empty
    end

    %w(h1 h2 h3 h4 h5 h6 p pre).each do |tag|
      it "should not wrap in p and not convert linebreaks inside #{tag} tags" do
        result = add_paragraphs_to_text("<#{tag}>A\nB\n\nC\n\n\nD</#{tag}")
        doc = Nokogiri::XML.fragment(result)
        doc.xpath("./#{tag}[1]").children.to_s.strip.should == "A\nB\n\nC\n\n\nD"
      end
    end

    %w(a abbr acronym).each do |tag|
      it "should wrap in p and not convert linebreaks inside #{tag} tags" do
        result = add_paragraphs_to_text("<#{tag}>A\nB\n\nC\n\n\nD</#{tag}")
        doc = Nokogiri::XML.fragment(result)
        doc.xpath("./p/#{tag}[1]").children.to_s.strip.should == "A\nB\n\nC\n\n\nD"
      end
    end

    it "should wrap plain text in p tags" do
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

    %w(adress b big cite code del dfn em i ins kbd q s samp
     small span strike strong sub sup tt u var).each do |tag|

      it "should handle #{tag} inline tags spanning double line breaks" do
        result = add_paragraphs_to_text("<#{tag}>some\n\ntext</#{tag}>")
        doc = Nokogiri::XML.fragment(result)
        doc.xpath("./p[1]/#{tag}").children.to_s.strip.should == "some" 
        doc.xpath("./p[2]/#{tag}").children.to_s.strip.should == "text"
      end
    end

    it "should handle nested inline tags spanning double line breaks" do
      result = add_paragraphs_to_text("<i><b>some\n\ntext</b></i>")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]/i/b").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]/i/b").children.to_s.strip.should == "text"
    end

    it "should handle nested inline tags spanning double line breaks" do
      result = add_paragraphs_to_text("<i>some <b>other\n\ntext</b></i>")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]/i").children.to_s.strip.should == "some <b>other</b>"
      doc.xpath("./p[2]/i/b").children.to_s.strip.should == "text"
    end

    %w(blockquote center div).each do |tag|
      it "should convert double linebreaks inside #{tag} tag" do
        result = add_paragraphs_to_text("<#{tag}>some\n\ntext</#{tag}>")
        doc = Nokogiri::XML.fragment(result)
        doc.xpath("./#{tag}/p[1]").children.to_s.strip.should == "some" 
        doc.xpath("./#{tag}/p[2]").children.to_s.strip.should == "text" 
      end
    end

    it "should keep attributes of block elements" do
      result = add_paragraphs_to_text("<div class='foo'>some\n\ntext</div>")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath(".div@class").should == "foo"
      doc.xpath("./div/p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./div/p[2]").children.to_s.strip.should == "text" 
    end

    it "should keep attributes of inline elements across paragraphs" do
      result = add_paragraphs_to_text("<span class='foo'>some\n\ntext</span>")
      doc = Nokogiri::XML.fragment(result)
      doc.xpath("./p[1]/span").children.to_s.strip.should == "some" 
      doc.xpath("./p[1]/span@class").should == "foo" 
      doc.xpath("./p[2]/span").children.to_s.strip.should == "text" 
      doc.xpath("./p[2]/span@class").should == "foo" 
    end

  end  

end
