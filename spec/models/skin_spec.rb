require 'spec_helper'

describe Skin do

  describe "save" do

    before(:each) do
      @skin = Skin.new(title: "Test Skin")
    end

    # good css
    {
      "allows basic CSS including font family" =>
        "body { background-color: #ffffff;}
         h1 { font-family: 'Fertigo Pro', Verdana, serif; }",

      "allows valid CSS shorthand values" =>
        "body {background:#ffffff url('http://mywebsite.com/img_tree.png') no-repeat right top;}",

      "allows images in the images directory" =>
        "body {background:#ffffff url('/images/img_tree.png') no-repeat right top;}",

      "allows unquoted URLs" =>
        "body {background:#ffffff url(http://mywebsite.com/images/img_tree.png) no-repeat right top;}",

      "allows comments on their own lines" =>
        "/* starting comment */
        li {color: green;}
        /* middle comment */
        dd {color: blue;}
        /* end comment */",

      "allows border-radius (CSS3 property)" =>
        ".profile { border-radius: 5px }",

      "allows specific border radius properties" =>
        ".profile { border-bottom-right-radius: 10px; }",

      "allows box-shadow (CSS3 property)" =>
        ".profile { box-shadow: 5px 5px 5px black; }",

      "allows alphabetic strings as keyword values even if they are not explicitly listed" =>
        "#main .navigation input { vertical-align: baseline; }
        #header .navigation li { text-transform: capitalize; }
        table { border-collapse: separate !important; }
        ",

      "allows valid CSS3 rules using quoted strings as content." =>
        "li.characters + li.freeforms:before {content: '||'}
        li.relationships + li.freeforms:before { content: 'Freeform: '; }
        li:before {content: url('http://foo.com/bullet.jpg')}",

      "allows whitelisted image extensions" =>
        ".a { background: url('http://example.com/i.jpg'); }
        .b { background: url('http://example.com/i.jpeg'); }
        .c { background: url('http://example.com/i.png'); }
        .d { background: url('http://example.com/i.gif'); }",

      "allows properties that are variations on the ones in the shorthand config list" =>
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
          text-shadow:-1px -1px 0 rgba(0,0,0,0.75);
        }
        ul.sorting  a:hover {
          background: rgba(71,71,71,1) 5% !important;
          color:rgba(254,254,254,1);
        }
        #main .navigation ul.sorting a:visited{
          color:rgba(254,254,254,1)
        }
        .flex-container {
          flex: 2 2 20em;
          flex-flow: row-reverse wrap;
        }",

      "allows gradients, clip, scale, skew, translate, rotate" =>
        "#main ul.sorting {
        background:-moz-linear-gradient(bottom, rgba(120,120,120,1) 5%, rgba(94,94,94,1) 50%, rgba(108,108,108,1) 55%, rgba(137,137,137,1) 100%) ;
        }
        ul.sorting  a:hover {
        background:-webkit-linear-gradient(bottom, rgba(71,71,71,1) 5%, rgba(59,59,59,1) 50%, rgba(74,74,74,1) 55%, rgba(91,91,91,1) 100%) !important;
        }
        #main .clip {clip: rect(1em, 2em, 3em, 4em);}
        #main li.blurb:nth-child(2n), #main.works-show .meta, .thread .thread li.comment:nth-child(3n+1) {-moz-transform: rotate(-0.5deg);}
        #main .foo {-moz-transform:rotate(120deg); -moz-transform:skewx(25deg) translatex(150px);}
        #menu {
        	background: -webkit-gradient(linear, left bottom, left top, color-stop(0, rgb(82,82,82)), color-stop(1, rgb(125,124,125)));
                    	-webkit-box-shadow: 0 1px 2px #000;
                    	-webkit-border-radius:2px;
                    	-webkit-transition:text-shadow .7s ease-out, background .7s ease-out;
                    	-webkit-transform: scale(2.1) rotate(-90deg)
        }
        #main .rotatevert {transform: rotatey(180deg);}
        .rotatehoriz {transform: rotatex(50deg)}",

        "allows multiple valid values for a single property" =>
        "#outer .actions a:hover,symbol .question:hover,.actions input:hover,#outer input[type=\"submit\"]:hover,button:hover,.actions label:hover
                { background:#ddd;
                background:-webkit-linear-gradient(top,#fafafa,#ddd);
                background:-moz-linear-gradient(top,#fafafa,#ddd);
                background:-ms-linear-gradient(top,#fafafa,#ddd);
                background:-o-linear-gradient(top,#fafafa,#ddd);
                background:linear-gradient(top,#fafafa,#ddd);
                color:#555 }",

      "allows display property with flex values" =>
        ".flex-container { display: flex; }
        .flex-container-inline { display: inline-flex; }",

      "allows align-content property" =>
        "div { align-content: flex-start; }",

      "allows align-items property" =>
        "div { align-items: stretch }",

      "allows align-self property" =>
        ".flex-item { align-self: center; }",

      "allows justify-content property" =>
        "div { justify-content: flex-end; }",

      "allows order property with negative value" =>
        "div { order: -1 }"
    }.each_pair do |condition, css|
      it condition do
        @skin.css = css
        expect(@skin.save).to be_truthy
      end
    end

    # This is verified to work in prod and staging, but not dev
    # TODO: fix across environments?
    xit "should save CSS3 box shadows with multiple shadows" do
      @skin.css = "li { box-shadow: 5px 5px 5px black, inset 0 0 0 1px #dadada; }"
      expect(@skin.save).to be_truthy
    end

    # bad bad bad css
    {
      "errors when saving garbage with braces" => "blhalkdfasd {ljaflkasjdflasd}",
      "errors when saving garbage with braces and colon" => "blhalkdfasd {ljaflkasjdflasd: }",
      "errors when saving garbage with invalid property" => "blhalkdfasd {ljaflkasjdflasd: aklsdfjsdf}",
      "errors when saving urls with xss" => "body {-moz-binding:url('http://ha.ckers.org/xssmoz.xml#xss')}",
      "errors when saving @font-face" => "@font-face { font-family: Delicious; src: url('Delicious-Roman.otf');}",
      "errors when saving @import" => "@import url('http://ha.ckers.org/xss.css');",
      "errors when saving src" => "body {border: src('http://foo.com/')}",
      "errors when saving url for font" => "body {font: url(http://foo.com/bar.png)}",
      "errors when saving htc urls" => "body {behavior: url(xss.htc);}",
      "errors when saving javascript in li" => "li {background-image: url(javascript:alert('XSS'));}",
      "errors when saving expression" => "div {width: expression(alert('XSS'));}",
      "errors when saving javascript with escaped quote" => "div {background-image: url(&#1;javascript:alert('XSS'))}",
      "errors when saving gradient with xss" => "div {background: -webkit-linear-gradient(url(xss.htc))}",
      "errors when saving dsf images" => "body {background: url(http://foo.com/bar.dsf)}",
      "errors when saving urls with invalid domain" => "body {background: url(http://foo.htc/bar.png)}",
      "errors when saving xss interrupted with comments" => "div {xss:expr/*XSS*/ession(alert('XSS'))}",
    }.each_pair do |condition, css|
      it condition do
        @skin.css = css
        expect(@skin.save).not_to be_truthy
        expect(@skin.errors[:base]).not_to be_empty
      end
    end

    it "requires a title" do
      @skin.title = ""
      expect(@skin.save).not_to be_truthy
      expect(@skin.errors[:title]).not_to be_empty
    end

    it "has a unique title" do
      expect(@skin.save).to be_truthy
      skin2 = Skin.new(title: "Test Skin")
      expect(skin2.save).not_to be_truthy
      expect(skin2.errors[:title]).not_to be_empty
    end

    it "requires a preview image if public" do
      @skin.css = "body {background: #fff;}"
      @skin.public = true
      expect(@skin.save).not_to be_truthy
      expect(@skin.errors[:base]).not_to be_empty
      expect(@skin.errors[:base].join(' ').match(/upload a screencap/)).to be_truthy
    end

    it "only allows valid media types" do
      @skin.media = ["foobar"]
      expect(@skin.save).not_to be_truthy
      expect(@skin.errors[:base]).not_to be_empty
      @skin.media = %w(screen print)
      expect(@skin.save).to be_truthy
      expect(@skin.errors[:base]).to be_empty
    end

    it "only allows valid roles" do
      @skin.role = "foobar"
      expect(@skin.save).not_to be_truthy
      expect(@skin.errors[:role]).not_to be_empty
      @skin.role = "override"
      expect(@skin.save).to be_truthy
      expect(@skin.errors[:role]).to be_empty
    end

    it "only allows valid ie-only conditions" do
      @skin.ie_condition = "foobar"
      expect(@skin.save).not_to be_truthy
      expect(@skin.errors[:ie_condition]).not_to be_empty
      @skin.ie_condition = "IE8_or_lower"
      expect(@skin.save).to be_truthy
      expect(@skin.errors[:ie_condition]).to be_empty
    end
  end


  describe "use" do
    before(:each) do
      Skin.load_site_css
      @css = "body {background: purple;}"
      @skin = Skin.new(title: "Test Skin", css: @css)
      @skin.save
      @style = @skin.get_style
    end

    it "has a valid style block" do
      style_regex = Regexp.new('<style type="text/css" media="all">')
      expect(@style.match(style_regex)).to be_truthy
    end

    it "includes the css" do
      expect(@style.match(/background: purple;/)).to be_truthy
    end

    it "includes links to the default archive skin" do
      expect(@style.match(/<link rel="stylesheet" type="text\/css"/)).to be_truthy
    end

  end

  describe ".approved_or_owned_by" do
    let(:skin_owner) { FactoryGirl.create(:user) }
    let(:random_user) { FactoryGirl.create(:user) }

    before do
      FactoryGirl.create(:private_work_skin, author: skin_owner, title: "Private Skin 1")
      FactoryGirl.create(:private_work_skin, author: skin_owner, title: "Private Skin 2")
    end

    context "no user argument given" do
      context "User.current_user is nil" do
        it "returns approved skins" do
          allow(User).to receive(:current_user).and_return(nil)
          expect(Skin.approved_or_owned_by.pluck(:title)).to eq(['Default'])
        end
      end

      context "when User.current_user is not nil" do
        context "user does not own skins" do
          it "returns approved skins" do
            allow(User).to receive(:current_user).and_return(random_user)
            expect(Skin.approved_or_owned_by.pluck(:title)).to eq(["Default"])
          end
        end

        context "user owns skins" do
          it "returns approved and owned skins" do
            allow(User).to receive(:current_user).and_return(skin_owner)
            expect(Skin.approved_or_owned_by.pluck(:title)).to eq(["Default", "Private Skin 1", "Private Skin 2"])
          end
        end
      end
    end

    context "user argument is given" do
      context "user is nil" do
        it "returns approved skins" do
          expect(Skin.approved_or_owned_by(nil).pluck(:title)).to eq(["Default"])
        end
      end

      context "user is not nil" do
        context "user does not own skins" do
          it "returns approved skins" do
            expect(Skin.approved_or_owned_by(random_user).pluck(:title)).to eq(["Default"])
          end
        end

        context "user owns skins" do
          it "returns approved and owned skins" do
            expect(Skin.approved_or_owned_by(skin_owner).pluck(:title)).to eq(["Default",
                                                                               "Private Skin 1",
                                                                               "Private Skin 2"])
          end
        end
      end
    end
  end

  describe ".approved_or_owned_by_any" do
    let(:users) { Array.new(3) { FactoryGirl.create(:user) } }

    context "users do not own skins" do
      it "returns approved skins" do
        expect(Skin.approved_or_owned_by_any(users).pluck(:title)).to eq(["Default"])
      end
    end

    context "users own skins" do
      before do
        FactoryGirl.create(:private_work_skin, author: users[1], title: "User 2's First Skin")
        FactoryGirl.create(:private_work_skin, author: users[1], title: "User 2's Second Skin")
        FactoryGirl.create(:private_work_skin, author: users[2], title: "User 3's Skin")
        FactoryGirl.create(:private_work_skin, title: "Unowned Private Skin")
      end

      it "returns approved and owned skins" do
        expect(Skin.approved_or_owned_by_any(users).pluck(:title)).to eq(["Default",
                                                                          "User 2's First Skin",
                                                                          "User 2's Second Skin",
                                                                          "User 3's Skin"])
      end

      it "does not return unassociated private work skins" do
        expect(Skin.approved_or_owned_by_any(users).pluck(:title)).not_to include(["Unowned Private Skin"])
      end
    end
  end
end

