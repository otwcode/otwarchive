require 'spec_helper'
require 'nokogiri'

describe XhtmlSplitter do
  include XhtmlSplitter
  
  describe "split_xhtml" do

    before(:each) do
      @html = """
        <div bgcolor=\"red\">
          <div>
            <p align=\"center\">
              one
            </p>
            <p>two</p>
            <p>thr<br/>ee</p>
            <p>for</p>
            <p>five</p>
            <hr/>
            <p><i>six</i></p>
            <p>seven</p>
            <p><b>eight</b></p>
            <p>nine</p>
            <p>ten</p>
         </div>
         <p>
           eleven
         </p>
       </div>
       """

    end
    
    it "should not touch small html" do
      split_xhtml(@html).should == [@html]
    end

    it "should split in two small parts" do
      result = split_xhtml(@html, 300)
      result.size.should == 2
      result[0].bytesize.should < 300
      result[1].bytesize.should < 300
    end
    
    it "should produce valid splitted XHTML parts" do
      result = split_xhtml(@html, 300)
      expect {
        Nokogiri::XML(result[0]){ |conf| conf.options = Nokogiri::XML::ParseOptions::STRICT }
        Nokogiri::XML(result[1]){ |conf| conf.options = Nokogiri::XML::ParseOptions::STRICT }
      }.to_not raise_error
   end

    it "should reopen red div in second part" do
      result = split_xhtml(@html, 300)
      doc = Nokogiri::HTML.fragment(result[1])
      doc.xpath("./div[@bgcolor='red']").should_not be_empty
    end
  end

  describe "stack_tags" do

    it "should ignore text-only" do
      stack_tags("test", ["<i>"]).should == ["<i>"]
    end
    
    it "should add opening tags" do
      stack_tags("<i>test", ["<p>"]).should == ["<p>", "<i>"]
    end

    it "should remove matching closing tags" do
      stack_tags("test</p>", ["<p>"]).should == []
    end
    
    it "should error on mismatched tags" do
      expect { stack_tags("test</div>", ["<p>"]) }.to raise_error
    end
    
    it "should ignore self-closing tags" do
      stack_tags("test<br /><br/>", []).should == []
    end

    it "should handle attributes when adding" do
      stack_tags('<p align="center">test', []).should == ['<p align="center">']
    end
    
    it "should handle attributes when removing" do
      stack_tags('test</p>', ['<p align="center">']).should == []
    end

    it "should handle multiple tags" do
      stack_tags("<p><em>test</em>", []).should == ["<p>"]
    end
    
  end


  describe "close_tags" do

    it "should close tags" do
      close_tags("test", ['<div>', '<p align="center">']).should == 'test</p></div>'
    end
  end

  describe "open_tags" do

    it "should open tags" do
      open_tags(['<div>', '<p align="center">']).should == "<div><p align=\"center\">\n"
    end
  end
end
