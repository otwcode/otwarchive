require File.dirname(__FILE__) + '/../test_helper'

require 'sanitize_params.rb'
require 'html_formatter.rb'

class HtmlFormatterTest < ActiveSupport::TestCase
  include HtmlFormatter
  
# temporary test suspension while we're working with the old parser

  def test_bad_self_closed_tag
    # illegally self-closed tag - test failing
    one_test '<a href="http:" />wiki</a>', '<p><a href="http:"></a>wiki</p>'
  end
  
  def test_start_with_closing_tag
    # text begins with close-tag
    one_test "</b> foo", "<p> foo</p>"
  end

  def test_identity_data
    one_test ""
    one_test "<p>1</p>"
    one_test "<p>1</p><p>2</p>"
    one_test "<p>1</p><p>2</p>"
    one_test "<p>1</p><p>2</p>"
  end

  def test_word
    one_test "word", "<p>word</p>"
  end

  def test_paragraph_manipulation
    one_test "<p></p>", ""
    one_test "<p></p><p></p><p></p>",  ""
    one_test "<p><p><p><p></p></p></p></p><p></p>",  ""
    one_test "text",  "<p>text</p>"
    one_test "<h1>head</h1>text",  "<h1>head</h1><p>text</p>"

    one_test "<p>words <i>word</i> words words</p>",  "<p>words <i>word</i> words words</p>"
    one_test "<p>words \"<i>quote</i>\" words words</p>",  "<p>words \"<i>quote</i>\" words words</p>"


    one_test "<div><div>chapter1</div></div><div>chapter1contentcontent</div>",  
      "<div>
  <div>
    <p>chapter1</p>
  </div>
</div><div>
  <p>chapter1contentcontent</p>
</div>"

    one_test "<div>chapter1</div><div>chapter1contentcontent</div>",  
      "<div>
  <p>chapter1</p>
</div><div>
  <p>chapter1contentcontent</p>
</div>"

    one_test "<p>  </p>",  ""
    one_test "<a href=\"xyz\"/><br/>text",  "<p><a href=\"xyz\"></a><br />text</p>"

    one_test "<p><a href=\"xyz\"/><br/>text</p>",  "<p><a href=\"xyz\"></a><br />text</p>"

    one_test "<b>title: </b> value<br/><b>title2</b> value 2",  "<p><b>title: </b> value<br /><b>title2</b> value 2</p>"
    one_test "<i><img src=\"gif.gif\">my post. <b>big</b> day!</i> more words",  
      "<p><i><img src=\"gif.gif\" />my post. <b>big</b> day!</i> more words</p>"
    one_test "<b><i><img src=\"gif.gif\">my post. <b>big</b> day!</i> more words",  
      "<p>
  <b><i><img src=\"gif.gif\" />my post. <b>big</b> day!</i> more words</b>
</p>"
  end

  def test_self_closing
    one_test "<b><i><img src=\"gif.gif\">my post. <b>big</b> day!</i> more words",  
      "<p>
  <b><i><img src=\"gif.gif\" />my post. <b>big</b> day!</i> more words</b>
</p>"
    one_test "<b><i><img src=\"gif.gif\"></img>my post. <b>big</b> day!</i> more words",  
      "<p>
  <b><i><img src=\"gif.gif\" />my post. <b>big</b> day!</i> more words</b>
</p>"
  end
  
  def test_doctype
    one_test "<!doctype blah blah>text", "<p>text</p>"
  end

  def test_xml_header
    one_test "<?xml blah blah?>text", "<p>text</p>"
  end

  def test_special_characters
    one_test "<p> a & b</p>",  "<p> a &amp; b</p>"
    one_test "<p> a &amp; b</p>",  "<p> a &amp; b</p>"
    one_test "<p> a &asd#p; b</p>",  "<p> a &amp;asd#p; b</p>"
    one_test "<p> a &#140; b</p>",  "<p> a &#140; b</p>"
    one_test "<p> a <3 b</p>",  "<p> a &lt;3 b</p>"
  end 

  def test_depth_of_tree
    one_test "<li>x\n"*2,  "<p>" + "<li>x\n</li>"*2 + "</p>"
    one_test "<li>x\n"*2000,  "<p>" + "<li>x\n</li>"*2000 + "</p>"
  end
    
  def test_line_breaks
    one_test "text1
text2

<hr />
text3
", "<p>text1<br />text2</p><hr /><p>text3</p>"

    one_test "This is a test
<i>Of a line</i> starting with the i tag.", "<p>This is a test<br/><i>Of a line</i> starting with the i tag.</p>"
    one_test "This is a test

<i>Of a line</i> starting with the i tag.", "<p>This is a test</p><p><i>Of a line</i> starting with the i tag.</p>"

    one_test "<p>1</p>
      <p  >
      2</ p >",  "<p>1</p><p>      2</p>"

    one_test "<p>chapter1
      line2
      line3

      newpara</p><div>chapter1contentcontent</div>",  
      "<p>chapter1<br/>      line2<br/>      line3</p><p>      newpara</p><div><p>chapter1contentcontent</p></div>"

    one_test "<p><p>chapter1
      line2
      line3

      newpara</p><div>chapter1contentcontent</div></p>",  
      "<p>chapter1<br/>      line2<br/>      line3</p><p>      newpara</p><div><p>chapter1contentcontent</p></div>"

    one_test '<center><p>text<br>text2</p></center>',  '<center><p>text<br/>text2</p></center>'
  end

  def test_attributes
    one_test '<div class="attrtest">line</div>',  '<div class="attrtest">
  <p>line</p>
</div>'
    one_test '<div class="attrtest attrtest2">line</div>',  '<div class="attrtest attrtest2">
  <p>line</p>
</div>'

    one_test "<xxx blah blah>text",  "<!--<xxx>--><!--</xxx>--><p>text</p>"
  end

  def test_unclosed_attribute
    one_test '<div class="attrtest attrtest2>line</div>',  '<div class="attrtest attrtest2"><p>line</p></div>'
  end
  
  def test_lt_in_title
    one_test '<span title="woo! <3">text</span>', '<p>
  <span title="woo! &lt;3">text</span>
</p>'
  end
  
  def test_many_lts
    one_test '(<.<)', '<p>(&lt;.&lt;)</p>'
  end

  def test_many_lts_in_tag
    one_test '<p>(<.<)</p>', '<p>(&lt;.&lt;)</p>'
  end

  def one_test(data, test_value=nil)
    require 'timeout'
    test_value ||= data
    mod_data = nil
    #Timeout.timeout(4) do
      mod_data = add_paragraph_tags_for_display data
    #end
    assert_equal test_value, mod_data
  end 

end
