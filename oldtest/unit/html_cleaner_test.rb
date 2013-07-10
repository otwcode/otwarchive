require 'test_helper'

require 'html_cleaner.rb'

class HtmlCleanerTest < ActiveSupport::TestCase

  # testing new parser
  def test_add_paragraphs
    test_sets = [
      {:in => "foo", :out => "\n  <p>foo</p>\n"},
      {:in => "<em><strong>foo</em></strong>", :out => "\n  <p>\n    <em>\n      <strong>foo</strong>\n    </em>\n  </p>\n"},
      {:in => "foo\n\nbar", :out => "\n  <p>foo</p>\n  <p>bar</p>\n"},
      {:in => "<h2>foo</h2>\n\nHere is my awesome doc.\n\n1. Awesome!\n2. More awesome!\n3. Still more!\n\n<blockquote>foobar</blockquote>", 
       :out => "\n  <h2>foo</h2>\n  <p>Here is my awesome doc.</p>\n  <p>1. Awesome!<br />2. More awesome!<br />3. Still more!</p>\n  <blockquote>\n    <p>foobar</p>\n  </blockquote>\n"},
      {:in => "<p>I want to put in my own paragraphs.</p>", :out => "\n  <p>I want to put in my own paragraphs.</p>\n"},
      {:in => "I want a whole bunch of\n\n\n\n\n\n\n\nwhitespace.", 
        :out => "\n  <p>I want a whole bunch of</p>\n  <p>&#xA0;</p>\n  <p>&#xA0;</p>\n  <p>whitespace.</p>\n"},
      {:in => "I don't want to put in my own paragraphs.\n\nBut I do want to put in\nmy own <br>linebreaks.", 
        :out => "\n  <p>I don't want to put in my own paragraphs.</p>\n  <p>But I do want to put in\nmy own <br />linebreaks.</p>\n"},
      {:in => "I am imported<br><br>from livejournal and have <br><br>double brs instead of paragraphs, ew.<br><br>", 
        :out => "\n  <p>I am imported</p>\n  <p>from livejournal and have </p>\n  <p>double brs instead of paragraphs, ew.</p>\n"},
      # {:in => "foo", :out => "foo"},
      # {:in => "foo", :out => "foo"},
      # {:in => "foo", :out => "foo"},
      # {:in => "foo", :out => "foo"},
    ]

    test_sets.each do |set|
      # puts "#{set[:in]} -> #{out} -> #{out.inspect}"
      assert_equal set[:out], add_paragraphs_to_text(set[:in])
    end
  end
    
  def test_strip
    str = '<h1>This</h1> is <img src="http://imgurl.co/here.jpg" /> an image here and 
      <div class="foobar">a div with class here</div> and 
      <div style="border: 1px solid black;">a div with style</div> here.'
        
    assert_equal '<h1>This</h1> is  an image here and 
      <div class="foobar">a div with class here</div> and 
      <div style="border: 1px solid black;">a div with style</div> here.', strip_images(str)
            
    assert_equal '<h1>This</h1> is <img src="http://imgurl.co/here.jpg" /> an image here and 
      <div class="foobar">a div with class here</div> and 
      <div>a div with style</div> here.', strip_styles(str)
                
    assert_equal '<h1>This</h1> is <img src="http://imgurl.co/here.jpg" /> an image here and 
      <div>a div with class here</div> and 
      <div style="border: 1px solid black;">a div with style</div> here.', strip_classes(str)

    assert_equal 'This is <img src="http://imgurl.co/here.jpg" /> an image here and 
      <div class="foobar">a div with class here</div> and 
      <div style="border: 1px solid black;">a div with style</div> here.', strip_obtrusive_tags(str)
  end

  def test_sanitizer
    
  end

end
