require 'spec_helper'

describe Skin do

  describe "save" do
    
    before(:each) do
      @skin = Skin.new(:title => "Test Skin")
    end
    
    # good css
    {
      "should allow through basic CSS including font family" => 
        "body { background-color: #ffffff;}
         h1 { font-family: 'Fertigo Pro', Verdana, serif; }",
      
      "should allow through valid CSS shorthand values" => 
        "body {background:#ffffff url('http://mywebsite.com/img_tree.png') no-repeat right top;}",

      "should allow images in the images directory" =>
        "body {background:#ffffff url('/images/img_tree.png') no-repeat right top;}",

      "should allow unquoted urls" =>
        "body {background:#ffffff url(http://mywebsite.com/images/img_tree.png) no-repeat right top;}",
      
      "should allow comments on their own lines" => 
        "/* starting comment */
        li {color: green;}
        /* middle comment */
        dd {color: blue;}
        /* end comment */",
        
      "should allow through border-radius (CSS3 property)" => 
        ".profile { border-radius: 5px }",

      ".should allow through specific border radius properties" =>
        ".profile { border-bottom-right-radius: 10px; }",

      "should allow through box-shadow (CSS3 property)" =>
        ".profile { box-shadow: 5px 5px 5px black; }",

      "should allow through alphabetic strings as keyword values even if they are not explicitly listed" => 
        "#main .navigation input { vertical-align: baseline; }
        #header .navigation li { text-transform: capitalize; }
        table { border-collapse: separate !important; }    
        ",

      "should allow through valid CSS3 rules using quoted strings as content." => 
        "li.characters + li.freeforms:before {content: '||'}
        li.relationships + li.freeforms:before { content: 'Freeform: '; }
        li:before {content: url('http://foo.com/bullet.jpg')}",
        
      "should allow through properties that are variations on the ones in the shorthand config list" => 
        "#main ul.sorting {
          background: rgba(120,120,120,1) 5%;
          -moz-border-radius:0.15em !important; 
          border-color:rgba(86,86,86,0.75) !important; 
          box-shadow:0 2px 5px rgba(0,0,0,0.5);
          float:none !important; 
          text-align:center; 
        }
        #main ul.sorting a {
          border-color:rgba(86,86,86,1) !important; 
          color:rgba(231,231,231,1); 
          text-shadow:-1px -1px 0 rgba(0,0,0,0.75)
        }
        ul.sorting  a:hover {
          background: rgba(71,71,71,1) 5% !important; 
          color:rgba(254,254,254,1);
        }
        #main .navigation ul.sorting a:visited{
          color:rgba(254,254,254,1)
        }",
      
      "should allow through gradients, scale, skew, translate, rotate" => 
        "#main ul.sorting {
        background:-moz-linear-gradient(bottom, rgba(120,120,120,1) 5%, rgba(94,94,94,1) 50%, rgba(108,108,108,1) 55%, rgba(137,137,137,1) 100%) ;
        }
        ul.sorting  a:hover {
        background:-webkit-linear-gradient(bottom, rgba(71,71,71,1) 5%, rgba(59,59,59,1) 50%, rgba(74,74,74,1) 55%, rgba(91,91,91,1) 100%) !important; 
        }
        #main li.blurb:nth-child(2n), #main.works-show .meta, .thread .thread li.comment:nth-child(3n+1) {-moz-transform: rotate(-0.5deg);}
        #main .foo {-moz-transform:rotate(120deg); -moz-transform:skewx(25deg) translatex(150px);}
        #menu {
        	background: -webkit-gradient(linear, left bottom, left top, color-stop(0, rgb(82,82,82)), color-stop(1, rgb(125,124,125)));
                    	-webkit-box-shadow: 0 1px 2px #000;
                    	-webkit-border-radius:2px;
                    	-webkit-transition:text-shadow .7s ease-out, background .7s ease-out;
                    	-webkit-transform: scale(2.1) rotate(-90deg)
        }",
        
        "should allow multiple valid values for a single property" =>
        "#outer .actions a:hover,symbol .question:hover,.actions input:hover,#outer input[type=\"submit\"]:hover,button:hover,.actions label:hover
                { background:#ddd; 
                background:-webkit-linear-gradient(top,#fafafa,#ddd); 
                background:-moz-linear-gradient(top,#fafafa,#ddd); 
                background:-ms-linear-gradient(top,#fafafa,#ddd); 
                background:-o-linear-gradient(top,#fafafa,#ddd); 
                background:linear-gradient(top,#fafafa,#ddd);
                color:#555 }"
    }.each_pair do |condition, css|
      it condition do 
        @skin.css = css
        @skin.save.should be_true
      end
    end

    # This is verified to work in prod and staging, but not dev
    # TODO: fix across environments?
    xit "should save CSS3 box shadows with multiple shadows" do
      @skin.css = "li { box-shadow: 5px 5px 5px black, inset 0 0 0 1px #dadada; }"
      @skin.save.should be_true
    end
    
    # bad bad bad css
    {
      "should not save garbage with braces" => "blhalkdfasd {ljaflkasjdflasd}",
      "should not save garbage with braces and colon" => "blhalkdfasd {ljaflkasjdflasd: }",
      "should not save garbage with invalid property" => "blhalkdfasd {ljaflkasjdflasd: aklsdfjsdf}",
      "should not save urls with xss" => "body {-moz-binding:url('http://ha.ckers.org/xssmoz.xml#xss')}",
      "should not save @font-face" => "@font-face { font-family: Delicious; src: url('Delicious-Roman.otf');}",
      "should not save @import" => "@import url('http://ha.ckers.org/xss.css');",
      "should not save src" => "body {border: src('http://foo.com/')}",
      "should not save url for font" => "body {font: url(http://foo.com/bar.png)}",
      "should not save htc urls" => "body {behavior: url(xss.htc);}",
      "should not save javascript in li" => "li {background-image: url(javascript:alert('XSS'));}",
      "should not save expression" => "div {width: expression(alert('XSS'));}",
      "should not save javascript with escaped quote" => "div {background-image: url(&#1;javascript:alert('XSS'))}",
      "should not save gradient with xss" => "div {background: -webkit-linear-gradient(url(xss.htc))}",
      "should not save dsf images" => "body {background: url(http://foo.com/bar.dsf)}",
      "should not save urls with invalid domain" => "body {background: url(http://foo.htc/bar.png)}",
      "should not save xss interrupted with comments" => "div {xss:expr/*XSS*/ession(alert('XSS'))}",
    }.each_pair do |condition, css|
      it condition do
        @skin.css = css
        @skin.save.should_not be_true
        @skin.errors[:base].should_not be_empty
      end
    end

    it "should have a unique title" do
      @skin.save.should be_true
      skin2 = Skin.new(:title => "Test Skin")
      skin2.save.should_not be_true
      skin2.errors[:title].should_not be_empty
    end
      
    it "should require a preview image if public" do
      @skin.css = "body {background: #fff;}"
      @skin.public = true
      @skin.save.should_not be_true
      @skin.errors[:base].should_not be_empty
      @skin.errors[:base].join(' ').match(/upload a screencap/).should be_true
    end
    
    it "should only allow valid media types" do
      @skin.media = ["foobar"]
      @skin.save.should_not be_true
      @skin.errors[:base].should_not be_empty
      @skin.media = %w(screen print)
      @skin.save.should be_true
      @skin.errors[:base].should be_empty
    end
      
    it "should only allow valid roles" do
      @skin.role = "foobar"
      @skin.save.should_not be_true
      @skin.errors[:role].should_not be_empty
      @skin.role = "override"
      @skin.save.should be_true
      @skin.errors[:role].should be_empty
    end
      
    it "should only allow valid ie-only conditions" do
      @skin.ie_condition = "foobar"
      @skin.save.should_not be_true
      @skin.errors[:ie_condition].should_not be_empty
      @skin.ie_condition = "IE8_or_lower"
      @skin.save.should be_true
      @skin.errors[:ie_condition].should be_empty
    end    
  end
    
    
  describe "use" do
    before(:each) do
      Skin.load_site_css
      @css = "body {background: purple;}"
      @skin = Skin.new(:title => "Test Skin", :css => @css)
      @skin.save
      @style = @skin.get_style
    end
    
    it "should have a valid style block" do
      style_regex = Regexp.new('<style type="text/css" media="all">')
      @style.match(style_regex).should be_true
    end
    
    it "should include the css" do
      @style.match(/background: purple;/).should be_true
    end
    
    it "should include links to the default archive skin" do
      @style.match(/<link rel="stylesheet" type="text\/css"/).should be_true
    end
    
  end
    
end

