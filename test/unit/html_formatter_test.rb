require 'test_helper'

require 'sanitize_params.rb'
require 'html_formatter.rb'

class HtmlFormatterTest < ActiveSupport::TestCase
  include HtmlFormatter

  def test_bad_self_closed_tag
    # illegally self-closed tag - test failing
    sanitize_and_format_test '<a href="http:" />wiki</a>', '<p><a href="http:"></a>wiki</p>'
  end
  
  def test_start_with_closing_tag
    # text begins with close-tag
    sanitize_and_format_test "</strong> foo", "<p> foo</p>"
  end

  def test_identity_data
    sanitize_and_format_test ""
    sanitize_and_format_test "<p>1</p>"
    sanitize_and_format_test "<p>1</p><p>2</p>"
    sanitize_and_format_test "<p>1</p><p>2</p>"
    sanitize_and_format_test "<p>1</p><p>2</p>"
  end

  def test_word
    sanitize_and_format_test "word", "<p>word</p>"
  end

  def test_paragraph_manipulation
    sanitize_and_format_test "<p></p>", ""
    sanitize_and_format_test "<p></p><p></p><p></p>",  ""
    sanitize_and_format_test "<p><p><p><p></p></p></p></p><p></p>",  ""
    sanitize_and_format_test "text",  "<p>text</p>"
    sanitize_and_format_test "<h1>head</h1>text",  "<h1>head</h1><p>text</p>"

    sanitize_and_format_test "<p>words <em>word</em> words words</p>",  "<p>words <em>word</em> words words</p>"
    sanitize_and_format_test "<p>words \"<em>quote</em>\" words words</p>",  "<p>words \"<em>quote</em>\" words words</p>"


    sanitize_and_format_test "<div><div>chapter1</div></div><div>chapter1contentcontent</div>",  
      "<div>
  <div>
    <p>chapter1</p>
  </div>
</div><div>
  <p>chapter1contentcontent</p>
</div>"

    sanitize_and_format_test "<div>chapter1</div><div>chapter1contentcontent</div>",  
      "<div>
  <p>chapter1</p>
</div><div>
  <p>chapter1contentcontent</p>
</div>"

    sanitize_and_format_test "<p>  </p>",  ""
    sanitize_and_format_test "<a href=\"xyz\"/><br/>text",  "<p><a href=\"xyz\"></a><br />text</p>"

    sanitize_and_format_test "<p><a href=\"xyz\"/><br/>text</p>",  "<p><a href=\"xyz\"></a><br />text</p>"

    sanitize_and_format_test "<strong>title: </strong> value<br/><strong>title2</strong> value 2",  "<p><strong>title: </strong> value<br /><strong>title2</strong> value 2</p>"
    sanitize_and_format_test "<em><img src=\"gif.gif\">my post. <strong>big</strong> day!</em> more words",  
      "<p><em><img src=\"gif.gif\" />my post. <strong>big</strong> day!</em> more words</p>"
    sanitize_and_format_test "<strong><em><img src=\"gif.gif\">my post. <strong>big</strong> day!</em> more words",  
      "<p>
  <strong><em><img src=\"gif.gif\" />my post. <strong>big</strong> day!</em> more words</strong>
</p>"
  end

  def test_self_closing
    sanitize_and_format_test "<strong><em><img src=\"gif.gif\">my post. <strong>big</strong> day!</em> more words",  
      "<p>
  <strong><em><img src=\"gif.gif\" />my post. <strong>big</strong> day!</em> more words</strong>
</p>"
    sanitize_and_format_test "<strong><em><img src=\"gif.gif\"></img>my post. <strong>big</strong> day!</em> more words",  
      "<p>
  <strong><em><img src=\"gif.gif\" />my post. <strong>big</strong> day!</em> more words</strong>
</p>"
  end
  
  # TODO: investigate
  # def test_doctype
  #   sanitize_and_format_test "<!doctype blah blah>text", "<p>text</p>"
  # end

  def test_xml_header
    sanitize_and_format_test "<?xml blah blah?>text", "<p>text</p>"
  end

  def test_special_characters
    sanitize_and_format_test "<p> a & b</p>",  "<p> a &amp; b</p>"
    sanitize_and_format_test "<p> a &amp; b</p>",  "<p> a &amp; b</p>"
    sanitize_and_format_test "<p> a &asd#p; b</p>",  "<p> a &amp;asd#p; b</p>"
    sanitize_and_format_test "<p> a &#x8C; b</p>",  "<p> a &#x8C; b</p>"
    #sanitize_and_format_test "<p> a <3 b</p>",  "<p> a &lt;3 b</p>"
  end 

  def test_depth_of_tree
    sanitize_and_format_test "<li>x\n"*2,  "<li>\n  <p>x<br /></p>\n</li>"*2  
    sanitize_and_format_test "<li>x\n"*2000,  "<li>\n  <p>x<br /></p>\n</li>"*2000
  end
    
  def test_line_breaks
    sanitize_and_format_test "text1
text2

<hr />
text3
", "<p>text1<br />text2</p><hr /><p><br />text3<br /></p>"

    sanitize_and_format_test "This is a test
<em>Of a line</em> starting with the i tag.", "<p>This is a test<br /><em>Of a line</em> starting with the i tag.</p>"
    sanitize_and_format_test "This is a test

<em>Of a line</em> starting with the i tag.", "<p>This is a test</p><p><em>Of a line</em> starting with the i tag.</p>"

    sanitize_and_format_test "<p>1</p>
      <p  >
      2</ p >",  "<p>1</p><p><br />      2 p &gt;</p>"

    sanitize_and_format_test "<p>chapter1
      line2
      line3

      newpara</p><div>chapter1contentcontent</div>",  
      "<p>chapter1<br />      line2<br />      line3</p><p>      newpara</p><div>\n  <p>chapter1contentcontent</p>\n</div>"

    sanitize_and_format_test "<p><p>chapter1
      line2
      line3

      newpara</p><div>chapter1contentcontent</div></p>",  
      "<p>chapter1<br />      line2<br />      line3</p><p>      newpara</p><div>\n  <p>chapter1contentcontent</p>\n</div>"

    sanitize_and_format_test '<center><p>text<br>text2</p></center>',  "<center>\n  <p>text<br />text2</p>\n</center>"
  end

  def test_attributes
    sanitize_and_format_test '<div class="attrtest">line</div>',  '<div class="attrtest">
  <p>line</p>
</div>'
    sanitize_and_format_test '<div class="attrtest attrtest2">line</div>',  '<div class="attrtest attrtest2">
  <p>line</p>
</div>'
    
    #TODO: prevent nesting
    sanitize_and_format_test "<xxx blah blah>text",  "<p>\n  <p>text</p>\n</p>"
  end

  def test_unclosed_attribute
    sanitize_and_format_test '<div class="attrtest attrtest2>line</div>',  '<div class="attrtest attrtest2&gt;line&lt;/div&gt;"></div>'
  end
  
  def test_lt_in_title
    sanitize_and_format_test '<span title="woo! <3">text</span>', '<p>
  <span title="woo! &lt;3">text</span>
</p>'
  end
  
  # def test_many_lts
  #   sanitize_and_format_test '(<.<)', '<p>(&lt;.&lt;)</p>'
  # end
  # 
  # def test_many_lts_in_tag
  #   sanitize_and_format_test '<p>(<.<)</p>', '<p>(&lt;.&lt;)</p>'
  # end

  def sanitize_and_format_test(data, test_value=nil)
    test_value ||= data
    mod_data = nil
    mod_data = sanitize_and_format_for_display data
    assert_equal test_value, mod_data
  end 

end
