# -*- coding: utf-8 -*-
require 'spec_helper'
require 'nokogiri'

describe HtmlCleaner do
  include HtmlCleaner

  describe "TagStack" do
    let(:stack) { TagStack.new }

    describe "inside paragraph?" do
      it "should return false" do
        stack.concat([[["div"], {}], [["i", {}]], [["s"], {}]])
        stack.inside_paragraph?.should be_false
      end

      it "should recognise paragraph in combination with i" do
        stack.concat([[["div", {}]], [["p", {}], ["i", {}]], [["s"], {}]])
        stack.inside_paragraph?.should be_true
      end

      it "should recognise paragraph in combination with i" do
        stack.concat([[["div", {}]], [["i", {}], ["p", {}]], [["s"], {}]])
        stack.inside_paragraph?.should be_true
      end

      it "should recognise single paragraph" do
        stack.concat([[["div", {}]], [["p", {}]], [["s", {}]]])
        stack.inside_paragraph?.should be_true
      end
    end

    describe "open_paragraph_tags" do
      it "should open tags" do
        stack.concat([[["div", {}]], [["p", {}], ["i", {}]], [["s", {}]]])
        stack.open_paragraph_tags.should == "<p><i><s>"
      end
      
      it "should open tags" do
        stack.concat([[["div", {}]], [["i", {}], ["p", {}]], [["s", {}]]])
        stack.open_paragraph_tags.should == "<p><s>"
      end

      it "should handle attributes" do
        stack.concat([[["div", {}]], [["p", {}]], [["s", {"color" => "blue"}]]])
        stack.open_paragraph_tags.should == "<p><s color='blue'>"
      end

      it "should ignore text nodes" do
        stack.concat([[["div", {}]], [["p", {}], ["s", {}]], [["text", {}]]])
        stack.open_paragraph_tags.should == "<p><s>"
      end
      
      it "should return empty string when not inside paragraph" do
        stack.concat([[["div", {}]], [["i", {}]], [["s", {}]]])
        stack.open_paragraph_tags.should == ""
      end

    end

    describe "close_paragraph_tags" do
      it "should close tags" do
        stack.concat([[["div", {}]], [["p", {}], ["i", {}]], [["s", {}]]])
        stack.close_paragraph_tags.should == "</s></i></p>"
      end
      
      it "should close tags" do
        stack.concat([[["div", {}]], [["i", {}], ["p", {}]], [["s", {}]]])
        stack.close_paragraph_tags.should == "</s></p>"
      end

      it "should handle attributes" do
        stack.concat([[["div", {}]], [["p", {}]], [["s", {"color" => "blue"}]]])
        stack.close_paragraph_tags.should == "</s></p>"
      end

      it "should ignore text nodes" do
        stack.concat([[["div", {}]], [["p", {}], ["s", {}]], [["text", {}]]])
        stack.close_paragraph_tags.should == "</s></p>"
      end

      it "should return empty string when not inside paragraph" do
        stack.concat([[["div", {}]], [["i", {}]], [["s", {}]]])
        stack.close_paragraph_tags.should == ""
      end
    end
    
    describe "close_and_pop_last" do
      it "should close tags" do
        stack.concat([[["div", {}]], [["p", {}], ["i", {}]]])
        stack.close_and_pop_last.should == "</i></p>"
        stack.should == [[["div", {}]]]
      end
    end

  end
  
  describe "close_unclosed_tag" do

    it "should close tag at end of line" do
      result = close_unclosed_tag("first <i>line\n second line", "i", 1)
      result.should == "first <i>line</i>\n second line"
    end

    %w(br col hr img).each do |tag|
      it "should not touch self-closing #{tag} tag" do
        result = close_unclosed_tag("don't <#{tag}> close", tag, 1)
        result.should == "don't <#{tag}> close"
      end
    end

    %w(col colgroup dl h1 h2 h3 h4 h5 h6 hr ol p pre table ul).each do |tag|
      it "should not touch #{tag} tags that don't go inside p tags" do
        result = close_unclosed_tag("don't <#{tag}> close", tag, 1)
        result.should == "don't <#{tag}> close"
      end
    end
    
    it "should close tag before next opening tag" do
      result = close_unclosed_tag("some <i>more<s>text</s>", "i", 1)
      result.should == "some <i>more</i><s>text</s>"
    end
    
    it "should close tag before next closing tag" do
      result = close_unclosed_tag("some <s><i>more text</s>", "i", 1)
      result.should == "some <s><i>more text</i></s>"
    end
    
    it "should close tag before next closing tag" do
      result = close_unclosed_tag("some <s><i>more text</s>", "i", 1)
      result.should == "some <s><i>more text</i></s>"
    end

    it "should close second opening tag" do
      result = close_unclosed_tag("some <i>more</i> <i>text", "i", 1)
      result.should == "some <i>more</i> <i>text</i>"
    end

    it "should only close specified tag" do
      result = close_unclosed_tag("<code><i>text", "strong", 1)
      result.should == "<code><i>text"
    end
  end


  describe "sanitize_value" do

    describe ":content" do

      it "should keep html" do
        value = "<em>hello</em> <blockquote>world</blockquote>"
        result = sanitize_value(:content, value)
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath(".//em").children.to_s.strip.should == "hello"
        doc.xpath(".//blockquote").children.to_s.strip.should == "world"
      end

      it "should keep valid unicode chars as is" do
        result = sanitize_value(:content, "„‚nörmäl’—téxt‘“")
        result.should =~ /„‚nörmäl’—téxt‘“/
      end
      
      it "should allow classes with letters, numbers and hyphens" do
        result = sanitize_value(:content, '<p class="f-5">foobar</p>')
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./p[@class='f-5']").children.to_s.strip.should == "foobar"
      end

      it "should allow not allow classes starting with numbers" do
        result = sanitize_value(:content, '<p class="8ball">foobar</p>')
        result.should_not =~ /8ball/
        result = sanitize_value(:content, '<p class="magic 8ball">foobar</p>')
        result.should_not =~ /8ball/
      end

      it "should allow not allow classes starting with hyphens" do
        result = sanitize_value(:content, '<p class="-dash">foobar</p>')
        result.should_not =~ /-dash/
        result = sanitize_value(:content, '<p class="rainbow -dash">foobar</p>')
        result.should_not =~ /-dash/
      end

      it "should allow not allow classes with special characters" do
        result = sanitize_value(:content, '<p class="foo@bar">foobar</p>')
        result.should_not =~ /foo@bar/
      end

      it "should allow two classes" do
        result = sanitize_value(:content, '<p class="foo bar">foobar</p>')
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./p[contains(@class, 'foo bar')]").children.to_s.strip.should == "foobar"
      end

      it "should allow RTL content in p" do
        html = '<p dir="rtl">This is RTL content</p>'
        result = sanitize_value(:content, html)
        result.should == html
      end

      it "should allow RTL content in div" do
        html = '<div dir="rtl"><p>This is RTL content</p></div>'
        result = sanitize_value(:content, html)
        # Yes, this is ugly. We should maybe try to figure out why our parser
        # wants to wrap All The Things in <p> tags.
        result.to_s.squish.should == '<p></p><div dir="rtl"> <p>This is RTL content</p> </div>'
      end

      it "should allow youtube embeds" do
        html = '<iframe width="560" height="315" src="http://www.youtube.com/embed/123" frameborder="0"></iframe>'
        result = sanitize_value(:content, html)
        result.should == html
      end

      it "should not allow iframes with unknown source" do
        html = '<iframe src="http://www.evil.org"></iframe>'
        result = sanitize_value(:content, html)
        result.should be_empty
      end

      it "should allow google player embeds" do
        html = '<embed type="application/x-shockwave-flash" flashvars="audioUrl=http://dl.dropbox.com/u/123/foo.mp3" src="http://www.google.com/reader/ui/123-audio-player.swf" width="400" height="27" allowscriptaccess="never" allownetworking="internal"></embed>'
        result = sanitize_value(:content, html)
        result.should == html
      end

      it "should not allow embeds with unknown source" do
        html = '<embed src="http://www.evil.org"></embed>'
        result = sanitize_value(:content, html)
        result.should be_empty
      end

      ["'';!--\"<XSS>=&{()}",
       '<XSS STYLE="behavior: url(xss.htc);">'
      ].each do |value|
        it "should strip xss tags: #{value}" do
          result = sanitize_value(:content, value)
          result.should_not =~ /xss/i
        end
      end

      ["<SCRIPT SRC=http://ha.ckers.org/xss.js></SCRIPT>",
       '<<SCRIPT>alert("XSS");//<</SCRIPT>',
       "<SCRIPT SRC=http://ha.ckers.org/xss.js?<B>",
       "<SCRIPT SRC=//ha.ckers.org/.j>",
       "<SCRIPT>alert(/XSS/.source)</SCRIPT>",
       '</TITLE><SCRIPT>alert("XSS");</SCRIPT>',
       '<SCRIPT SRC="http://ha.ckers.org/xss.jpg"></SCRIPT>'
      ].each do |value|
        it "should strip script tags: #{value}" do
          result = sanitize_value(:content, value)
          result.should_not =~ /script/i
          result.should_not =~ /ha.ckers.org/
        end
      end

      ["\\\";alert('XSS');//",
       "xss:expr/*blah*/ession(alert('XSS'))",
       "xss:expression(alert('XSS'))"
       ].each do |value|
        it "should keep text: #{value}" do
          result = sanitize_value(:content, value)
          result.should =~ /alert\('XSS'\)/
        end
      end

      it "should strip iframe tags" do
        value = "<iframe src=http://ha.ckers.org/scriptlet.html <"
        result = sanitize_value(:content, value)
        result.should_not =~ /iframe/i
          result.should_not =~ /ha.ckers.org/
      end

      ["<IMG SRC=\"javascript:alert('XSS');\">",
       "<IMG SRC=JaVaScRiPt:alert('XSS')>",
       "<IMG SRC=javascript:alert(String.fromCharCode(88,83,83))>",
       "<IMG SRC=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>",
       "<IMG SRC=&#0000106&#0000097&#0000118&#0000097&#0000115&#0000099&#0000114&#0000105&#0000112&#0000116&#0000058&#0000097&#0000108&#0000101&#0000114&#0000116&#0000040&#0000039&#0000088&#0000083&#0000083&#0000039&#0000041>",
       "<IMG SRC=&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29>",
       "<IMG SRC=\" &#14;  javascript:alert('XSS');\">",
       "<IMG SRC=\"javascript:alert('XSS')\"",
       "<INPUT TYPE=\"IMAGE\" SRC=\"javascript:alert('XSS');\">",
       "<IMG SRC=\"jav	ascript:alert('XSS');\">",
       "<IMG SRC=\"jav&#x09;ascript:alert('XSS');\">",
       "<IMG SRC=\"jav&#x0A;ascript:alert('XSS');\">",
       "<IMG SRC=\"jav&#x0D;ascript:alert('XSS');\">",
      ].each do |value|
        
        it "should strip javascript in img src attribute: #{value[0..40]}" do
          result = sanitize_value(:content, value)
          result.should_not =~ /xss/i
          result.should_not =~ /javascript/i
        end
      end
       
      ['<META HTTP-EQUIV="Link" Content="<http://ha.ckers.org/xss.css>; REL=stylesheet">',
       "<META HTTP-EQUIV=\"refresh\" CONTENT=\"0;url=javascript:alert('XSS');\">",
       '<META HTTP-EQUIV="refresh" CONTENT="0;url=data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K">',
       "<META HTTP-EQUIV=\"refresh\" CONTENT=\"0; URL=http://;URL=javascript:alert('XSS');\">",
       "<META HTTP-EQUIV=\"Set-Cookie\" Content=\"USERID=&lt;SCRIPT&gt;alert('XSS')&lt;/SCRIPT&gt;\">"
      ].each do |value|
        it "should strip xss in meta tags: #{value[0..40]}" do
          result = sanitize_value(:content, value)
          result.should_not =~ /javascript/i
          result.should_not =~ /xss/i
        end
      end
       
      it "should strip xss inside tags" do
        value = '<IMG """><SCRIPT>alert("XSS")</SCRIPT>">'
        result = sanitize_value(:content, value)
        result.should_not =~ /script/i
      end

      it "should strip script/xss tags" do
        value = '<SCRIPT/XSS SRC="http://ha.ckers.org/xss.js"></SCRIPT>'
        result = sanitize_value(:content, value)
        result.should_not =~ /script/i
        result.should_not =~ /xss/i
        result.should_not =~ /ha.ckers.org/
      end
      
      it "should strip script/src tags" do
        value = '<SCRIPT/SRC="http://ha.ckers.org/xss.js"></SCRIPT>'
        result = sanitize_value(:content, value)
        result.should_not =~ /script/i
        result.should_not =~ /xss/i
        result.should_not =~ /ha.ckers.org/
      end

      it "should strip xss in body background" do
        value = "<BODY BACKGROUND=\"javascript:alert('XSS')\">"
        result = sanitize_value(:content, value)
        result.should_not =~ /xss/i
      end
      
      ["<BODY ONLOAD=alert('XSS')>",
       '<BODY onload!#$%&()*~+-_.,:;?@[/|\]^`=alert("XSS")>',
      ].each do |value|
        it "should strip xss in body onload: #{value}" do
          result = sanitize_value(:content, value)
          result.should_not =~ /xss/i
          result.should_not =~ /onload/i
        end
      end

      it "should strip style tag" do
        value = "<STYLE>@import'http://ha.ckers.org/xss.css';</STYLE>"
        result = sanitize_value(:content, value)
        result.should_not =~ /style/i
      end

      it "should handle lone @imports" do
        value = "@import'http://ha.ckers.org/xss.css';"
        result = sanitize_value(:content, value)
        result.should_not =~ /style/i
        result.should =~ /@import/i
      end

      it "should handle lone borked @imports" do
        value = "@im\port'\ja\vasc\ript:alert(\"XSS\")';"
        result = sanitize_value(:content, value)
        result.should_not =~ /style/i
        result.should =~ /@im\port/i
      end

      it "should strip javascript from img dynsrc" do
        value = "<IMG DYNSRC=\"javascript:alert('XSS')\">"
        result = sanitize_value(:content, value)
        result.should_not =~ /javascript/i
        result.should_not =~ /xss/i
      end

      it "should strip javascript from img lowsrc" do
        value = "<IMG DYNSRC=\"javascript:alert('XSS')\">"
        result = sanitize_value(:content, value)
        result.should_not =~ /javascript/i
        result.should_not =~ /xss/i
      end

      it "should strip javascript from bgsound src" do
        value = "<BGSOUND SRC=\"javascript:alert('XSS');\">"
        result = sanitize_value(:content, value)
        result.should_not =~ /javascript/i
        result.should_not =~ /xss/i
      end

      it "should strip javascript from br size" do
        value = "<BR SIZE=\"&{alert('XSS')}\">"
        result = sanitize_value(:content, value)
        result.should_not =~ /xss/i
      end

      it "should strip javascript from link href" do
        value = "<LINK REL=\"stylesheet\" HREF=\"javascript:alert('XSS');\">"
        result = sanitize_value(:content, value)
        result.should_not =~ /javascript/i
        result.should_not =~ /xss/i
      end

      it "should strip xss from link href" do
        value = '<LINK REL="stylesheet" HREF="http://ha.ckers.org/xss.css">'
        result = sanitize_value(:content, value)
        result.should_not =~ /ha.ckers.org/i
        result.should_not =~ /xss/i
      end

      it "should strip namespace tags" do
        value = '<HTML xmlns:xss><?import namespace="xss" implementation="http://ha.ckers.org/xss.htc"><xss:xss>Blah</xss:xss></HTML>'
        result = sanitize_value(:content, value)
        result.should_not =~ /xss/i
        result.should_not =~ /ha.ckers.org/i
        result.should =~ /Blah/
      end

      it "should strip javascript in style=background-image" do
        value = "<span style=background-image:url(\"javascript:alert('XSS')\");>Text</span>"
        result = sanitize_value(:content, value)
        result.should_not =~ /xss/i
        result.should_not =~ /javascript/i
      end

      it "should strip script tags" do
        value = "';alert(String.fromCharCode(88,83,83))//\\';alert(String.fromCharCode(88,83,83))//\";alert(String.fromCharCode(88,83,83))//\\\";alert(String.fromCharCode(88,83,83))//--></SCRIPT>\">'><SCRIPT>alert(String.fromCharCode(88,83,83))</SCRIPT>"
        result = sanitize_value(:content, value)
        result.should_not =~ /xss/i
        result.should_not =~ /javascript/i
      end

      ["<!--#exec cmd=\"/bin/echo '<SCR'\"-->",
       "<!--#exec cmd=\"/bin/echo 'IPT SRC=http://ha.ckers.org/xss.js></SCRIPT>'\"-->"
      ].each do |value|
        it "should strip #exec: #{value[0..40]}" do
          result = sanitize_value(:content, value)
          result.should == ""
        end
      end

      
      # TODO: Ones with all types of quote marks:
      # "<IMG SRC=`javascript:alert("RSnake says, 'XSS'")`>"


      it "should escape ampersands" do
        result = sanitize_value(:content, "& &amp;")
        result.should =~ /&amp; &amp;/
      end
    
    end

    # TODO: other fields 

  end
  

  describe "fix_bad_characters" do
    
    it "should not touch normal text" do
      fix_bad_characters("normal text").should == "normal text"
    end

    it "should not touch normal text with valid unicode chars" do
      fix_bad_characters("„‚nörmäl’—téxt‘“").should == "„‚nörmäl’—téxt‘“"
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

    %w(a abbr acronym address).each do |tag|
      it "should not add extraneous paragraph breaks after #{tag} tags" do
        result = add_paragraphs_to_text("<#{tag}>quack</#{tag}> quack")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath(".//p").size.should == 1
        doc.xpath(".//br").should be_empty
      end
    end

    it "should not convert linebreaks after p tags" do
      result = add_paragraphs_to_text("<p>A</p>\n<p>B</p>\n\n<p>C</p>\n\n\n")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath(".//p").size.should == 3
      doc.xpath(".//br").should be_empty
    end

    %w(dl h1 h2 h3 h4 h5 h6 ol pre table ul).each do |tag|
      it "should not convert linebreaks after #{tag} tags" do
        result = add_paragraphs_to_text("<#{tag}>A</#{tag}>\n<#{tag}>B</#{tag}>\n\n<#{tag}>C</#{tag}>\n\n\n")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath(".//p").size.should == 0
        doc.xpath(".//br").should be_empty
      end
    end
    
    %w(blockquote center div).each do |tag|
      it "should not convert linebreaks after #{tag} tags" do
        result = add_paragraphs_to_text("<#{tag}>A</#{tag}>\n<#{tag}>B</#{tag}>\n\n<#{tag}>C</#{tag}>\n\n\n")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath(".//p").size.should == 4
        doc.xpath(".//br").should be_empty
      end
    end
    
    it "should not convert linebreaks after br tags" do
      result = add_paragraphs_to_text("A<br>B<br>\n\nC<br>\n\n\n")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath(".//p").size.should == 1
      doc.xpath(".//br").size.should == 3
    end    

    it "should not convert linebreaks after hr tags" do
      result = add_paragraphs_to_text("A<hr>B<hr>\n\nC<hr>\n\n\n")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath(".//p").size.should == 3
      doc.xpath(".//br").should be_empty
    end    

    %w(dl h1 h2 h3 h4 h5 h6 ol pre table ul).each do |tag|
      it "should not wrap #{tag} in p tags" do
        result = add_paragraphs_to_text("aa <#{tag}>foo</#{tag}> bb")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath(".//p").size.should == 2
        doc.xpath(".//#{tag}").children.to_s.strip.should == "foo"
      end
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
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./#{tag}/li[1]").children.to_s.strip.should == "A" 
        doc.xpath("./#{tag}/li[2]").children.to_s.strip.should == "B"
        doc.xpath(".//br").should be_empty
      end
    end

    it "should not convert linebreaks inside tables" do
      html = """
      <table>
        <tr>
          <th>A</th>
          <th>B</th>
        </tr>
        <tr>
          <td>C</td>
          <td>D</td>
        </tr>
      </table> 
      """
      
      result = add_paragraphs_to_text(html)
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./table/tr[1]/th[1]").children.to_s.strip.should == "A" 
      doc.xpath("./table/tr[1]/th[2]").children.to_s.strip.should == "B" 
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
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./dl/dt[1]").children.to_s.strip.should == "A" 
      doc.xpath("./dl/dd[1]").children.to_s.strip.should == "aaa" 
      doc.xpath("./dl/dt[2]").children.to_s.strip.should == "B" 
      doc.xpath("./dl/dd[2]").children.to_s.strip.should == "bbb" 
      doc.xpath(".//br").should be_empty
    end

    %w(address h1 h2 h3 h4 h5 h6 p pre).each do |tag|
      it "should not wrap in p and not convert linebreaks inside #{tag} tags" do
        result = add_paragraphs_to_text("<#{tag}>A\nB\n\nC\n\n\nD</#{tag}>")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./#{tag}[1]").children.to_s.strip.should == "A\nB\n\nC\n\n\nD"
      end
    end

    %w(a abbr acronym).each do |tag|
      it "should wrap in p and not convert linebreaks inside #{tag} tags" do
        result = add_paragraphs_to_text("<#{tag}>A\nB\n\nC\n\n\nD</#{tag}>")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./p/#{tag}[1]").children.to_s.strip.should == "A\nB\n\nC\n\n\nD"
      end
    end

    it "should wrap plain text in p tags" do
      result = add_paragraphs_to_text("some text")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some text" 
    end

    it "should convert single linebreak to br" do
      result = add_paragraphs_to_text("some\ntext")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should =~ /some<br\/?>text/ 
    end

    it "should convert double linebreaks to paragraph break" do
      result = add_paragraphs_to_text("some\n\ntext")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]").children.to_s.strip.should == "text" 
    end

    it "should convert triple linebreaks into blank paragraph" do
      result = add_paragraphs_to_text("some\n\n\ntext")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]").children.to_s.strip.should == "&#160;" 
      doc.xpath("./p[3]").children.to_s.strip.should == "text" 
    end
  
    it "should convert double br tags into paragraph break" do
      result = add_paragraphs_to_text("some<br/>\n<br/>text")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]").children.to_s.strip.should == "text" 
    end

    it "should convert triple br tags into blank paragraph" do
      result = add_paragraphs_to_text("some<br/>\n<br/>\n<br/>text")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]").children.to_s.strip.should == "&#160;" 
      doc.xpath("./p[3]").children.to_s.strip.should == "text" 
    end

    it "should not convert double br tags inside p tags" do
      result = add_paragraphs_to_text("<p>some<br/>\n<br/>text</p>")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath(".//p").size.should == 1
      doc.xpath(".//br").size.should == 2
    end

    it "should not convert triple br tags inside p tags" do
      result = add_paragraphs_to_text("<p>some<br/>\n<br/>\n<br/>text</p>")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath(".//p").size.should == 1
      doc.xpath(".//br").size.should == 3
    end

    %w(b big cite code del dfn em i ins kbd q s samp
     small span strike strong sub sup tt u var).each do |tag|

      it "should handle #{tag} inline tags spanning double line breaks" do
        result = add_paragraphs_to_text("<#{tag}>some\n\ntext</#{tag}>")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./p[1]/#{tag}").children.to_s.strip.should == "some" 
        doc.xpath("./p[2]/#{tag}").children.to_s.strip.should == "text"
      end
    end

    it "should handle nested inline tags spanning double line breaks" do
      result = add_paragraphs_to_text("<i>have <b>some\n\ntext</b> yay</i>")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]/i").children.to_s.strip.should =~ /\Ahave/
      doc.xpath("./p[1]/i/b").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]/i/b").children.to_s.strip.should == "text"
      doc.xpath("./p[2]/i").children.to_s.strip.should =~ / yay\Z/
    end

    it "should handle nested inline tags spanning double line breaks" do
      result = add_paragraphs_to_text("have <em>some\n\ntext</em> yay")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should =~ /\Ahave/
      doc.xpath("./p[1]/em").children.to_s.strip.should == "some" 
      doc.xpath("./p[2]/em").children.to_s.strip.should == "text"
      doc.xpath("./p[2]").children.to_s.strip.should =~ / yay\Z/
    end

    %w(blockquote center div).each do |tag|
      it "should convert double linebreaks inside #{tag} tag" do
        result = add_paragraphs_to_text("<#{tag}>some\n\ntext</#{tag}>")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./#{tag}/p[1]").children.to_s.strip.should == "some" 
        doc.xpath("./#{tag}/p[2]").children.to_s.strip.should == "text" 
      end
    end

    it "should wrap text in p before and after existing p tag" do
      result = add_paragraphs_to_text("boom\n\n<p>da</p>\n\nyadda")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]").children.to_s.strip.should == "boom" 
      doc.xpath("./p[2]").children.to_s.strip.should == "da" 
      doc.xpath("./p[3]").children.to_s.strip.should == "yadda" 
    end

    it "should keep attributes of block elements" do
      result = add_paragraphs_to_text("<div class='foo'>some\n\ntext</div>")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./div[@class='foo']/p[1]").children.to_s.strip.should == "some"
      doc.xpath("./div[@class='foo']/p[2]").children.to_s.strip.should == "text"
    end

    it "should keep attributes of inline elements across paragraphs" do
      result = add_paragraphs_to_text("<span class='foo'>some\n\ntext</span>")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]/span[@class='foo']").children.to_s.strip.should == "some"
      doc.xpath("./p[2]/span[@class='foo']").children.to_s.strip.should == "text"
    end

    it "should handle two classes" do
      result = add_paragraphs_to_text('<p class="foo bar">foobar</p>')
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[contains(@class, 'foo')]").children.to_s.strip.should == "foobar"
      doc.xpath("./p[contains(@class, 'bar')]").children.to_s.strip.should == "foobar"
    end

    it "should close unclosed inline tags before double linebreak" do
      html = """Here is an unclosed <em>em tag.
    
      Here is an unclosed <strong>strong tag.

      Stuff."""

      doc = Nokogiri::HTML.fragment(add_paragraphs_to_text(html))
      doc.xpath("./p[1]/em").children.to_s.strip.should == "em tag." 
      doc.xpath("./p[2]/strong").children.to_s.strip.should == "strong tag."
      doc.xpath("./p[3]").children.to_s.strip.should == "Stuff."
    end

    it "should close unclosed tag withing other tag" do
      pending "Opened bug report with Nokogiri"
      html = "<strong><em>unclosed</strong>"
      doc = Nokogiri::HTML.fragment(add_paragraphs_to_text(html))
      doc.xpath("./p/strong/em").children.to_s.strip.should == "unclosed"
    end

    it "should re-nest mis-nested tags" do
      html = "some <em><strong>text</em></strong>"
      doc = Nokogiri::HTML.fragment(add_paragraphs_to_text(html))
      doc.xpath("./p[1]/em/strong").children.to_s.strip.should == "text" 
    end

    it "should handle mixed uppercase/lowecase html tags" do
      result = add_paragraphs_to_text("<em>mixed</EM> <EM>stuff</em>")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p[1]/em[1]").children.to_s.strip.should == "mixed" 
      doc.xpath("./p[1]/em[2]").children.to_s.strip.should == "stuff" 
    end

    %w(b big cite code del dfn em i ins kbd q s samp
     small span strike strong sub sup tt u var).each do |tag|
      it "should wrap consecutive #{tag} inline tags in one paragraph " do
        if tag == "sup" || tag == "sub"
          pending "Opened bug report with Nokogiri"
        end
        result = add_paragraphs_to_text("<#{tag}>hey</#{tag}> <#{tag}>ho</#{tag}>")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./p[1]/#{tag}[1]").children.to_s.strip.should == "hey" 
        doc.xpath("./p[1]/#{tag}[2]").children.to_s.strip.should == "ho"
        doc.xpath("./p[1]/text()").to_s.should == " "
      end
    end

    %w(&gt; &lt; &amp;).each do |entity|
      it "should handle #{entity}" do
        result = add_paragraphs_to_text("#{entity}")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./p[1]").children.to_s.strip.should == "#{entity}" 
      end
    end

    it "should not add empty p tags" do
      result = add_paragraphs_to_text("A<p>B</p><p>C</p>")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./p").size.should == 3
      doc.xpath("./p[1]").children.to_s.strip.should == "A" 
      doc.xpath("./p[2]").children.to_s.strip.should == "B" 
      doc.xpath("./p[3]").children.to_s.strip.should == "C" 
    end

    it "should not leave p inside i" do
      result = add_paragraphs_to_text("<i><p>foo</p><p>bar</p></i>")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath(".//i/p").should be_empty
    end

    it "should deal with br tags at the beginning" do
      result = add_paragraphs_to_text("<br/></br>text")
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath(".//p").children.to_s.strip.should == "text" 
    end


    it "should handle table tags that don't need closing" do
      html = """
      <table> 
        <colgroup align=\"left\"><col width=\"20\"></colgroup>
        <colgroup align=\"right\">
        <tr> 
          <th>A</th> 
          <th>B</th> 
        </tr> 
        <tr> 
          <td>C</td>
          <td>D</td>
        </tr>
      </table>
     """
      result = add_paragraphs_to_text(html)
      doc = Nokogiri::HTML.fragment(result)
      doc.xpath("./table/colgroup[@align='left']/col[@width='20']").size.should == 1
      doc.xpath("./table/colgroup[@align='right']").size.should == 1
      doc.xpath("./table/tr[1]/th[1]").children.to_s.strip.should == "A" 
      doc.xpath("./table/tr[1]/th[2]").children.to_s.strip.should == "B" 
      doc.xpath("./table/tr[2]/td[1]").children.to_s.strip.should == "C" 
      doc.xpath("./table/tr[2]/td[2]").children.to_s.strip.should == "D" 
    end

    
    %w(script style).each do |tag|
      it "should keep #{tag} tags as is" do
        result = add_paragraphs_to_text("<#{tag}>keep me</#{tag}>")
        doc = Nokogiri::HTML.fragment(result)
        doc.xpath("./p/#{tag}").children.to_s.strip.should == "keep me"
      end
    end

    it "should fail gracefully for missing ending quotation marks" do
      pending "Opened enhancement request with Nokogiri"
      result = add_paragraphs_to_text("<strong><a href='ao3.org>mylink</a></strong>")
      doc = Nokogiri::HTML.fragment(result)
      node = doc.xpath(".//a").first
      node.attribute("href").value.should_not =~ /strong/
      node.text.strip.should == "mylink"
    end
    
    it "should fail gracefully for missing starting quotation marks" do
      result = add_paragraphs_to_text('<strong><a href=ao3.org">mylink</a></strong>')
      doc = Nokogiri::HTML.fragment(result)
      node = doc.xpath(".//a").first
      node.attribute("href").value.should == "ao3.org%22"
      node.text.strip.should == "mylink"
    end

  end  
end
