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
              one one one one one
            </p>
            <p>two two two two two</p>
            <p>three<br/>three</p>
            <p>four four four four</p>
            <p>five five five five</p>
            <hr/>
            <p><i>six</i> six six six six</p>
            <p>seven seven seven seven seven</p>
            <p><b>eight </b>eight eight eight</p>
            <p>nine</p>
            <p>ten</p>
         </div>
         <p>
           eleven
         </p>
       </div>
       """

    end

    it "should not split small html" do
      expect(split_xhtml(@html).size).to eq(1)
    end

    it "should split in two small parts" do
      result = split_xhtml(@html, 300)
      expect(result.size).to eq(2)
      expect(result[0].bytesize).to be < 300
      expect(result[1].bytesize).to be < 300
    end

    it "should split in two small parts if html is a single line" do
      result = split_xhtml(@html.gsub("\n", ""), 300)
      expect(result.size).to eq(2)
      expect(result[0].bytesize).to be < 300
      expect(result[1].bytesize).to be < 300
    end

    it "should handle html with more than one root element" do
      result = split_xhtml("<p>aaa</p>" * 40, 300)
      expect(result.size).to eq(2)
      doc = Nokogiri::HTML.fragment(result[0])
      expect(doc.xpath("./p").size).to be > 1
      doc = Nokogiri::HTML.fragment(result[1])
      expect(doc.xpath("./p").size).to be > 1
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
      expect(doc.xpath("./div[@bgcolor='red']")).not_to be_empty
    end
  end

  describe "stack_tags" do

    it "should ignore text-only" do
      expect(stack_tags("test", ["<i>"])).to eq(["<i>"])
    end

    it "should add opening tags" do
      expect(stack_tags("<i>test", ["<p>"])).to eq(["<p>", "<i>"])
    end

    it "should remove matching closing tags" do
      expect(stack_tags("test</p>", ["<p>"])).to eq([])
    end

    it "should error on mismatched tags" do
      expect { stack_tags("test</div>", ["<p>"]) }.to raise_error
    end

    it "should ignore self-closing tags" do
      expect(stack_tags("test<br /><br/>", [])).to eq([])
    end

    it "should handle attributes when adding" do
      expect(stack_tags('<p align="center">test', [])).to eq(['<p align="center">'])
    end

    it "should handle attributes when removing" do
      expect(stack_tags('test</p>', ['<p align="center">'])).to eq([])
    end

    it "should handle multiple tags" do
      expect(stack_tags("<p><em>test</em>", [])).to eq(["<p>"])
    end

  end


  describe "close_tags" do

    it "should close tags" do
      expect(close_tags("test", ['<div>', '<p align="center">'])).to eq('test</p></div>')
    end
  end

  describe "open_tags" do

    it "should open tags" do
      expect(open_tags(['<div>', '<p align="center">'])).to eq("<div><p align=\"center\">\n")
    end
  end
end
