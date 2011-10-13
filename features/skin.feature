@skins
Feature: creating and editing skins
  
  Scenario: A user's initial skin should be set to default
  Given basic skins
    And I am logged in as "skinner"
  When I am on skinner's preferences page
  Then "Default" should be selected within "preference_skin_id"
  
  Scenario: A user should be able to choose a different public skin in their preferences
  Given basic skins
    And the approved public skin "public skin" with css "#title { text-decoration: blink;}"
    And I am logged in as "skinner"
  When I change my skin to "public skin"
  When I am on skinner's preferences page
  Then "public skin" should be selected within "preference_skin_id"
    And I should see "text-decoration: blink;" within "style"
  
  Scenario: A user should be able to create a skin with CSS
  Given basic skins
    And I am logged in as "skinner"
  When I am on skin's new page
    And I fill in "Title" with "my blinking skin"
    And I fill in "CSS" with "#title { text-decoration: blink;}"
    And I press "Create"
  Then I should see "Skin was successfully created"
    And I should see "my blinking skin skin by skinner"
    And I should see "text-decoration: blink;"
    And I should see "(No Description Provided)"
    And I should see "by skinner"
    But I should find "Use"
    And I should find "Delete"
    And I should find "Edit"
    And I should not find "Stop Using"
    And I should not see "(Approved)"
    And I should not see "(Not yet reviewed)"
  
  Scenario: A logged-out user should not be able to create skins.
  When I am on skin's new page
    Then I should see "Sorry, you don't have permission"

  ########################################################
  ##### Here we check for things that should be allowed by the sanitizer
  
  Scenario: The sanitizer should allow through basic CSS including font-family
  Given I am logged in as "skinner"
  When I create the skin "valid skin" with css
      """  
      body { background-color: #ffffff;}
      h1 { font-family: 'Fertigo Pro', Verdana, serif; }
      """
  Then I should see "Skin was successfully created"
    And I should see "background-color: #ffffff;"
    And I should see "font-family: 'Fertigo Pro', Verdana, serif"

  Scenario: The sanitizer should allow through valid CSS shorthand values
  Given I am logged in as "skinner"
  When I create the skin "valid skin" with css
      """  
      body {background:#ffffff url('http://mywebsite.com/img_tree.png') no-repeat right top;}
      """
  Then I should see "Skin was successfully created"
    And I should see "url('http://mywebsite.com/img_tree.png')"
    And I should see "no-repeat"

  Scenario: The sanitizer should allow comments on their own lines
  Given I am logged in as "skinner"
  When I create the skin "valid skin" with css
      """  
      /* starting comment */
      li {color: green;}
      /* middle comment */
      dd {color: blue;}
      /* end comment */
      """
  Then I should see "Skin was successfully created"
    And I should see "starting comment"
    And I should see "middle comment"
    And I should see "end comment"
    And I should see "color: green"
    And I should see "color: blue"

  Scenario: The sanitizer should allow through CSS3 properties like border-bottom-right-radius and box-shadow
  Given I am logged in as "skinner"
  When I create the skin "CSS3 skin" with css
      """  
      .profile .module h3, .media-index li.category h3 { border-left: 4px double #111 !important; border-bottom-right-radius: 0 !important; }
      li {box-shadow: inset 0 0px 20px 1px #fff, 0px 1px 0 rgba(140,120,50,0.75), 0 6px 0px #1f3053, 0 8px 4px 1px #111}
      """
  Then I should see "Skin was successfully created"
    And I should see "border-bottom-right-radius: 0 !important"
    And I should see "box-shadow"
    And I should see "inset 0 0px 20px 1px #fff, 0px 1px 0 rgba(140,120,50,0.75), 0 6px 0px #1f3053, 0 8px 4px 1px #111"

  Scenario: The sanitizer should allow through alphabetic strings as keyword values even if they are not explicitly listed
  Given I am logged in as "skinner"
  When I create the skin "valid skin" with css
      """  
      #main .navigation input { vertical-align: baseline; }
      #header .navigation li { text-transform: capitalize; }
      table { border-collapse: separate !important; }    
      """
  Then I should see "Skin was successfully created"
    And I should see "baseline"
    And I should see "capitalize"
    And I should see "separate"

  Scenario: The css sanitizer should allow through valid CSS3 rules using quoted strings as content.
  Given I am logged in as "skinner"
  When I create the skin "CSS3 skin with content" with css
      """  
      li.characters + li.freeforms:before {content: '||'}
      li.relationships + li.freeforms:before { content: 'Freeform: '; }
      li:before {content: url('http://foo.com/bullet.jpg')}
      """
  Then I should see "Skin was successfully created"
    And I should see "content: '||'"
    And I should see "content: 'Freeform: '"
    And I should see "content: url('http://foo.com/bullet.jpg')"


  Scenario: The sanitizer should allow through properties that are variations on the ones in the shorthand config list
  Given I am logged in as "skinner"
  When I create the skin "valid skin" with css
      """  
      #main ul.sorting {
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
      }
      """
    Then I should see "Skin was successfully created"
      And I should see "rgba(254,254,254,1)"
      And I should see "-moz-border-radius"


  Scenario: The sanitizer should allow through gradients, scale, skew, translate, rotate
  Given I am logged in as "skinner"
  When I create the skin "valid skin" with css
      """  
      #main ul.sorting {
      background:-moz-linear-gradient(bottom, rgba(120,120,120,1) 5%, rgba(94,94,94,1) 50%, rgba(108,108,108,1) 55%, rgba(137,137,137,1) 100%) ;
      }
      ul.sorting  a:hover {
      background:-webkit-linear-gradient(bottom, rgba(71,71,71,1) 5%, rgba(59,59,59,1) 50%, rgba(74,74,74,1) 55%, rgba(91,91,91,1) 100%) !important; 
      }
      #main li.blurb:nth-child(2n), #main.works-show .meta, .thread .thread li.comment:nth-child(3n+1) {-moz-transform: rotate(-0.5deg);}
      #main .foo {-moz-transform:rotate(120deg); -moz-transform:skewx(25deg) translatex(150px);}
      #menu {
      	background: -webkit-gradient(linear, left bottom, left top, color-stop(0, rgb(82,82,82)), color-stop(1, rgb(125,124,125)));
                  	-webkit-box-shadow:#000 0 1px 2px;
                  	-webkit-border-radius:2px;
                  	-webkit-transition:text-shadow .7s ease-out, background .7s ease-out;
                  	-webkit-transform: scale(2.1) rotate(-90deg)
      }
      """
  Then I should see "Skin was successfully created"
    And I should see "-moz-linear-gradient"
    And I should see "-webkit-linear-gradient"
    And I should see "rotate(-0.5deg)"
    And I should see "skewx(25deg)"
    And I should see "translatex(150px)"
    And I should see "-webkit-gradient(linear, left bottom, left top, color-stop(0, rgb(82,82,82)), color-stop(1, rgb(125,124,125)));"
    And I should see "scale"
    And I should see "rotate"    

  # model for creating new "should allow" tests
  # Scenario: The sanitizer should allow through 
  # Given I am logged in as "skinner"
  # When I create the skin "valid skin" with css
  #     """  
  #     """
  # Then I should see "Skin was successfully created"
  #   And I should see ""

  ########################################################
  ##### Here we check for things that should NOT be allowed by the sanitizer

  Scenario: A user should not be able to enter total garbage CSS
  Given I am logged in as "skinner"
    And I set up the skin "Evil Skin"
  When I fill in "CSS" with "blah blah blah blah alsdfjaslfd lasdjfadf askdjflsa"
    And I press "Create"
  Then I should see "We couldn't find any valid CSS rules in that code"
  When I fill in "CSS" with "blhalkdfasd {ljaflkasjdflasd}"
    And I press "Create"
  Then I should see "don't seem to be any rules"
  When I fill in "CSS" with "blhalkdfasd {ljaflkasjdflasd: }"
    And I press "Create"
  Then I should see "There don't seem to be any rules"
  When I fill in "CSS" with "blhalkdfasd {ljaflkasjdflasd: aklsdfjsdf}"
    And I press "Create"
  Then I should see "We don't currently allow the CSS property"
    And I should see "There don't seem to be any rules"

  Scenario: A user should not be able to use various dangerous things like @font-face and @import.
  Given I am logged in as "skinner"
    And I set up the skin "Evil Skin"
  When I fill in "CSS" with "body {-moz-binding:url('http://ha.ckers.org/xssmoz.xml#xss')}"
    And I press "Create"
  Then I should see "We don't currently allow the CSS property -moz-binding"
  When I fill in "CSS" with "@font-face { font-family: Delicious; src: url('Delicious-Roman.otf');}"
    And I press "Create"
  Then I should see "We don't allow the @font-face feature."
  When I fill in "CSS" with "@import url('http://ha.ckers.org/xss.css');"
    And I press "Create"
  Then I should see "We couldn't find any valid CSS rules in that code"
  When I fill in "CSS" with "body {border: src('http://foo.com/')}"
  Then I should see "We couldn't find any valid CSS rules in that code."

  Scenario: A user should not be able to use various dangerous values like urls in properties where they are not allowed and evil urls
  Given I am logged in as "skinner"
    And I set up the skin "Evil Skin"
  When I fill in "CSS" with "body {font: url(http://foo.com/bar.png)}"
    And I press "Create"
  Then I should see "The font property in body cannot have the value url(http://foo.com/bar.png)"
  When I fill in "CSS" with "body {behavior: url(xss.htc);}"
    And I press "Create"
  Then I should see "The behavior property in body cannot have the value url(xss.htc)"
  When I fill in "CSS" with "li {background-image: url(javascript:alert('XSS'));}"
    And I press "Create"
  Then I should see "The background-image property in li cannot have the value url(javascript:alert('XSS'))"
  When I fill in "CSS" with "div {width: expression(alert('XSS'));}"
    And I press "Create"
  Then I should see "The width property in div cannot have the value expression(alert('XSS'))"
  When I fill in "CSS" with "div {background-image: url(&#1;javascript:alert('XSS'))}"
    And I press "Create"
  Then I should see "The background-image property in div cannot have the value url(javascript:alert('XSS'))"
  When I fill in "CSS" with "div {background: -webkit-linear-gradient(url(xss.htc))}"
    And I press "Create"
  Then I should see "The background property in div cannot have the value -webkit-linear-gradient(url(xss.htc))"
  When I fill in "CSS" with "div {background: -webkit-linear-gradient(url('xss.htc'))}"
    And I press "Create"
  Then I should see "The background property in div cannot have the value -webkit-linear-gradient(url('xss.htc'))"
  
  Scenario: A user should only be able to use urls for valid image types and from valid top-level domains
  Given I am logged in as "skinner"
    And I set up the skin "Evil Skin"
  When I fill in "CSS" with "body {background: url(http://foo.com/bar.dsf)}"
    And I press "Create"
  Then I should see "The background property in body cannot have the value url(http://foo.com/bar.dsf)"
  When I fill in "CSS" with "body {background: url(http://foo.htc/bar.png)}"
    And I press "Create"
  Then I should see "The background property in body cannot have the value url(http://foo.htc/bar.png)"

  Scenario: If a user tries to get around our rules with quotes we should strip out evil code
  Given I am logged in as "skinner"
    And I set up the skin "Evil Skin"
  When I fill in "CSS" with "div {xss:expr/*XSS*/ession(alert('XSS'))}"
    And I press "Create"
  Then I should see "We couldn't find any valid CSS rules in that code"
    And I should not see "expression"
    And I should not see "xss:"
    And I should not see "alert"  
  
  Scenario: A user should be able to select one of their own non-public skins to use in their preferences
  Given I am logged in as "skinner" 
    And I create the skin "my blinking skin" with css "#title { text-decoration: blink;}"
  When I am on skinner's preferences page
    And I select "my blinking skin" from "preference_skin_id"
    And I press "Update"
  Then I should see "Your preferences were successfully updated."
    And I should see "#title {" within "style"
    And I should see "text-decoration: blink;" within "style"
  
  Scenario: A user should be able to select one of their own non-public skins to use in their My Skins page
  Given I am logged in as "skinner" 
    And I create the skin "my blinking skin" with css "#title { text-decoration: blink;}"
  When I follow "My Skins"
  Then I should see "my blinking skin"
    And I should find "Use"
  When I press "Use"
  Then I should see "#title {" within "style"
    And I should see "text-decoration: blink;" within "style"
    
  Scenario: Skin titles should be unique
  Given I am logged in as "skinner" 
  When I am on skin's new page
    And I fill in "Title" with "Default"
    And I press "Create"
  Then I should see "must be unique"
  
  Scenario: Only public skins should be on the main skins page
  Given basic skins
    And I am logged in as "skinner" 
    And I create the skin "my skin"
  When I am on the skins page
  Then I should not see "my skin"
    And I should see "Default"
    
  Scenario: The user who creates a skin should be able to edit it
  Given I am logged in as "skinner" 
    And I create the skin "my skin"
    And I follow "My Skins"
  When I follow "Edit"
    And I fill in "CSS" with "#greeting { text-decoration: blink;}"
    And I press "Update"
  Then I should see "Skin updated"  
  
  Scenario: Public skins should require a preview image
  Given I am logged in as "skinner" 
    And I am on skin's new page
  When I fill in "Title" with "public skin"
    And I fill in "CSS" with "#title { text-decoration: blink;}"
    And I fill in "Description" with "Blinky love"
    And I check "skin_public"
    And I press "Create"
  Then I should see "You need to upload a screencap"
  When I attach the file "test/fixtures/skin_test_preview.png" to "skin_icon"
    And I press "Create"
  Then I should see "Skin was successfully created"
  
  Scenario: Newly created public skins should not appear on the main skins page until approved and should be
    marked as not-yet-approved
  Given I am logged in as "skinner" 
    And the unapproved public skin "public skin"
  When I am on the skins page
    Then I should not see "public skin"
  When I follow "My Skins"
  Then I should see "public skin"
    And I should see "(Not yet reviewed)"
    And I should not see "(Approved)"
    
  Scenario: Public skins should not be viewable by users until approved
  Given the unapproved public skin "public skin"
    And I am logged out
  When I go to "public skin" skin page
    Then I should see "Sorry, you don't have permission"
  When I go to "public skin" edit skin page
    Then I should see "Sorry, you don't have permission"
  When I go to admin's skins page
    Then I should see "I'm sorry, only an admin can"
  
  Scenario: Users should not be able to see the admin skins page
  Given I am logged in as "skinner" 
  When I go to admin's skins page
  Then I should see "I'm sorry, only an admin can look at that area"
  
  Scenario: Admins should be able to see public skins in the admin skins page
  Given the unapproved public skin "public skin"
    And I am logged in as an admin
  When I go to admin's skins page  
  Then I should see "public skin" within "table#unapproved"
  
  Scenario: Admins should not be able to edit unapproved skins
  Given the unapproved public skin "public skin"
    And I am logged in as an admin
  When I go to "public skin" skin page
  Then I should not find "Edit"
    And I should not find "Delete"
  When I go to "public skin" edit skin page
  Then I should see "Sorry, you don't have permission"
    
  Scenario: Admins should be able to approve public skins
  Given the unapproved public skin "public skin"
    And I am logged in as an admin
  When I go to admin's skins page  
    And I check "public skin"
    And I press "Update"
  Then I should see "The following skins were approved: public skin"
  When I follow "Approved Skins"
  Then I should see "public skin" within "table#approved"
  
  Scenario: Admins should be able to edit but not delete public approved skins
  Given the approved public skin "public skin" with css "#title { text-decoration: blink;}"
    And I am logged in as an admin
  When I go to "public skin" skin page
  Then I should see "Edit"
    But I should not find "Delete"
  When I follow "Edit"
    And I fill in "CSS" with "#greeting.logged-in { text-decoration: blink;}"
    And I fill in "Description" with "Blinky love (admin modified)"
    And I press "Update"
  Then I should see "Skin updated"
    And I should see "(admin modified)"
    And I should see "#greeting.logged-in"
    And I should not see "#title"
  
  Scenario: Users should not be able to edit their public approved skins
  Given the approved public skin "public skin"
    And I am logged in as "skinner" 
  Then I should see "Hi, skinner!"
  When I go to "public skin" edit skin page
  Then I should see "Sorry, you don't have permission"
  When I follow "My Skins"
  Then I should see "(Approved)"
    And I should not see "Edit"
  
  Scenario: Users should be able to use public approved skins created by others
  Given the approved public skin "public skin" with css "#title { text-decoration: blink;}"
    And I am logged in as "skinuser" 
    And I am on skinuser's preferences page
  When I select "public skin" from "preference_skin_id"
    And I press "Update"
  Then I should see "Your preferences were successfully updated."
    And "public skin" should be selected within "preference_skin_id"
    And I should see "#title {" within "style"
    And I should see "text-decoration: blink;" within "style"
    
  Scenario: Admins should be able to unapprove public skins, which should also remove them from preferences
  Given "skinuser" is using the approved public skin "public skin" with css "#title { text-decoration: blink;}"
    And I unapprove the skin "public skin"
  Then I should see "The following skins were unapproved and removed from preferences: public skin"
    And I should see "public skin" within "table#unapproved"
  When I am logged in as "skinuser" 
    And I am on skinuser's preferences page
  Then "Default" should be selected within "preference_skin_id"
    And I should not see "#title {" within "style"
    And I should not see "text-decoration: blink;" within "style"
  
  Scenario: Users should be able to create a skin using the wizard
  Given basic skins
  When I am on the skins page
  Then I should see "Default by AO3"
  Given I am logged in as "skinner" 
  When I am on skin's new page
  Then I should see "CSS" within "dl"
  When I follow "Use Wizard Instead?"
  Then I should see "Archive Skin Wizard"
    And I should not see "CSS" within "dl"
  When I follow "Write Custom CSS Instead?"
  Then I should see "CSS" within "dl"
  When I follow "Use Wizard Instead?"
    And I fill in "Title" with "Wide margins"
    And I fill in "Description" with "Layout skin"
    And I fill in "skin_margin" with "text"
    And I press "Create"
  Then I should see a save error message
    And I should see "Margin is not a number"
  When I fill in "skin_margin" with "5"
    And I press "Create"
  Then I should see "Skin was successfully created"
    And I should see "Margin5"
  When I follow "Edit"
    And I follow "Use Wizard Instead?"
    And I fill in "skin_margin" with "4.5"
    And I fill in "skin_font" with "Garamond"
    And I fill in "skin_background_color" with "#ccccff"
    And I fill in "skin_foreground_color" with "red"
    And I fill in "skin_base_em" with "120"
    And I fill in "skin_paragraph_margin" with "5"
    And I press "Update"
    # TODO: Think about whether rounding to 4 is actually the right behaviour or not
  Then I should see "Skin updated"
    And I should see "4"
    And I should not see "4.5"
  When I am on skinner's preferences page
  Then "Default" should be selected within "preference_skin_id"
  When I select "Wide margins" from "preference_skin_id"
    And I press "Update"
  Then I should see "Your preferences were successfully updated."
    And I should see "#chapters {margin: auto 4% 2.5em; padding: 0.5em 4% 0;}" within "style"
    And I should see "background: #ccccff;" within "style"
    And I should see "color: red;" within "style"
    And I should see "font: 120%/1.125 Garamond;" within "style"
    And I should see "#main .userstuff p {margin-bottom: 5.0em;}" within "style"
  When I am on skinner's preferences page
  Then "Wide margins" should be selected within "preference_skin_id"
  
  Scenario: Users should be able to create and use a work skin
  Given I am logged in as "skinner" 
  When I am on skin's new page
    And I select "Work Skin" from "skin_type"
    And I fill in "Title" with "Awesome Work Skin"
    And I fill in "Description" with "Great work skin"
    And I fill in "CSS" with "p {color: purple;}"
    And I press "Create"
  Then I should see "Skin was successfully created"
    And I should see "#workskin p"
  When I go to the new work page
  Then I should see "Awesome Work Skin"
  When I set up the draft "Story With Awesome Skin"
    And I select "Awesome Work Skin" from "work_work_skin_id"
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see "color: purple" within "style"
  When I press "Post"
  Then I should see "Story With Awesome Skin"
    And I should see "color: purple" within "style"
    And I should see "Hide Creator's Style"
  When I follow "Hide Creator's Style"
  Then I should see "Story With Awesome Skin"
    And I should not see "color: purple" within "style"
    And I should not see "Hide Creator's Style"
    And I should see "Show Creator's Style"
  
  Scenario: Log out from my skins page (Issue 2271)  
  Given I am logged in as "skinner"
    And I am on my user page
  When I follow "My Skins"
    And I follow "Log out"
  Then I should be on the login page
  
  Scenario: Change the header color
  Given I am logged in as "skinner"
  When I create a skin to change the header color
  Then I should see a different header color
  
  Scenario: Change the accent color
  Given I am logged in as "skinner"
  When I create a skin to change the accent color
  Then I should see a different accent color on the dashboard and work meta
