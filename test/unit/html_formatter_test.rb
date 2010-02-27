require File.dirname(__FILE__) + '/../test_helper'

require 'sanitize_params.rb'
require 'html_formatter.rb'

class HtmlFormatterTest < ActiveSupport::TestCase
  include HtmlFormatter

    @@identity_data = [
      "",
      "<p>1</p>",
      "<p>1</p><p>2</p>",
      "<p>1</p><p>2</p>",
      "<p>1</p><p>2</p>",
    ]
    @@bad_data = {
      "word" => "<p>word</p>",
      "<p></p>" => "",
      "<!doctype blah blah>text" => "<p>text</p>",
      "<?xml blah blah?>text" => "<p>text</p>",
      "<xxx blah blah>text" => "<!--<xxx>--><!--</xxx>--><p>text</p>",
      "<p></p><p></p><p></p>" => "",
      "<p><p><p><p></p></p></p></p><p></p>" => "",
      "text" => "<p>text</p>",
      "<h1>head</h1>text" => "<p><h1><p>head</p></h1>text</p>",

      "<p>words <i>word</i> words words</p>" => "<p>words <i>word</i> words words</p>",
      "<p>words \"<i>quote</i>\" words words</p>" => "<p>words \"<i>quote</i>\" words words</p>",

      "<p>1</p>
      <p  >
      2</ p >" => "<p>1</p><p>      2</p>",

      "<p>chapter1
      line2
      line3

      newpara</p><div>chapter1contentcontent</div>" => 
      "<p>chapter1<br/>      line2<br/>      line3</p><p>      newpara</p><div><p>chapter1contentcontent</p></div>",

      "<p><p>chapter1
      line2
      line3

      newpara</p><div>chapter1contentcontent</div></p>" => 
      "<p>chapter1<br/>      line2<br/>      line3</p><p>      newpara</p><div><p>chapter1contentcontent</p></div>",

      "<div><div>chapter1</div></div><div>chapter1contentcontent</div>" => 
      "<div><div><p>chapter1</p></div></div><div><p>chapter1contentcontent</p></div>",

      "<div>chapter1</div><div>chapter1contentcontent</div>" => 
      "<div><p>chapter1</p></div><div><p>chapter1contentcontent</p></div>",

      "<p>  </p>" => "",

      "<a href=\"xyz\"/><br/>text" => "<p><a href=\"xyz\"></a><br/>text</p>",

      "<p><a href=\"xyz\"/><br/>text</p>" => "<p><a href=\"xyz\"></a><br/>text</p>",

      "<b>title: </b> value<br/><b>title2</b> value 2" => "<p><b>title: </b> value<br/><b>title2</b> value 2</p>",

      "<i><img src=\"gif.gif\">my post. <b>big</b> day!</i> more words" => "<p><i><img src=\"gif.gif\"></img>my post. <b>big</b> day!</i> more words</p>",
      "<b><i><img src=\"gif.gif\">my post. <b>big</b> day!</i> more words" => "<p><b></b><i><img src=\"gif.gif\"></img>my post. <b>big</b> day!</i> more words</p>",

      "<p> a & b</p>" => "<p> a &amp; b</p>",
      "<p> a &amp; b</p>" => "<p> a &amp; b</p>",
      "<p> a &asd#p; b</p>" => "<p> a &amp;asd#p; b</p>",
      "<p> a &#140; b</p>" => "<p> a &#140; b</p>",
      "<p> a <3 b</p>" => "<p> a &lt;3 b</p>",
      "<li>x\n"*2 => "<p>" + "<li>x\n</li>"*2 + "</p>",
      "<li>x\n"*2000 => "<p>" + "<li>x\n</li>"*2000 + "</p>",
#      "<p><div>large text block here\nThere should eb very much text</p>"*20000 => "<p><div></div>large text block here\nThere should eb very much text</p>"*20000,
      "text1
text2

<hr />
text3
" => "<p>text1<br/>text2</p><hr/><p>text3</p>",

      "This is a test.

<i>Of a line</i> starting with the i tag." => "<p>This is a test<br/><i>Of a line</i> starting with the i tag.</p>"
      
    }

  def testit
    require 'timeout'

    m = add_paragraph_tags_for_display ' <p></p>'
    assert_equal '', m

    @@identity_data.each do |data|
      mod_data = nil
      begin
        mod_data = nil
        Timeout.timeout(10) do
          mod_data = add_paragraph_tags_for_display data
        end
        assert_equal data, mod_data
      rescue e
        flunk "Error: #{e}"
      end
    end
    @@bad_data.each do |k,v|
      begin
        mod_data = nil
        Timeout.timeout(10) do
          mod_data = add_paragraph_tags_for_display k
        end
        assert_equal mod_data, v, k
      rescue Exception, Timeout::Error => e
        flunk "Error: #{e}\n#{e.backtrace.join("\n")}\n (#{k})"
      end
    end
  end
end
