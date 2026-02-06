require "spec_helper"
require "nokogiri"

describe ParagraphMaker do
  include ParagraphMaker

  describe "process" do
    it "converts single linebreaks to br and wrap with p" do
      result = process(Nokogiri::HTML5.fragment("some\ntext"))
      expect(result.to_html).to eq("<p>some<br>\ntext</p>")
    end

    it "converts double linebreaks to paragraph break and keep separate lines" do
      result = process(Nokogiri::HTML5.fragment("some\n\ntext"))
      expect(result.to_html).to eq("<p>some</p>\n<p>text</p>")
    end

    it "converts five linebreaks to blank paragraph and keep separate lines" do
      result = process(Nokogiri::HTML5.fragment("a paragraph\n\n\n\n\nanother paragraph"))
      expect(result.to_html).to eq(<<~HTML.strip)
        <p>a paragraph</p>
        <p>&nbsp;</p>
        <p>another paragraph</p>
      HTML
    end
  end
end
