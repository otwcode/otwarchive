@skins
Feature: creating and editing skins

  Scenario: A user should not be able to put evil code into skins. 
  Given I am logged in as "skinner" with password "password"
  When I am on skin's new page
    And I fill in "Title" with "Evil Skin"
    And I fill in "CSS" with "body {-moz-binding:url('http://ha.ckers.org/xssmoz.xml#xss')}"
    And I press "Create"
  Then I should see "code for body doesn't seem to be a valid CSS rule"
  When I fill in "CSS" with "body {behavior: url(xss.htc);}"
    And I press "Create"
  Then I should see "The behavior property in body cannot have the value url(xss.htc)"
  When I fill in "CSS" with "body {@import 'http://ha.ckers.org/xss.css';}"
    And I press "Create"
  Then I should see "The code for body doesn't seem to be a valid CSS rule."
  When I fill in "CSS" with "li {background-image: url(javascript:alert('XSS'));}"
    And I press "Create"
  Then I should see "The code for li doesn't seem to be a valid CSS rule"
  When I fill in "CSS" with "div {width: expression(alert('XSS'));}"
    And I press "Create"
  Then I should see "The width property in div cannot have the value"
  When I fill in "CSS" with "div {background-image: url(&#1;javascript:alert('XSS'))}"
    And I press "Create"
  Then I should see "The code for div doesn't seem to be a valid CSS rule"
  When I fill in "CSS" with "div {xss:expr/*XSS*/ession(alert('XSS'))}"
    And I press "Create"
  Then I should see "Skin was created successfully"
    And I should see "/*XSS*/"
    And I should not see "expression"
    And I should not see "xss:"
    And I should not see "alert"

  Scenario: Only the user who creates a skin should be able to edit it
    and only if it's not official

  Given basic skins
  When I am on the skins page
  Then I should see "Default by AO3"
    And I should see "Plain Text by AO3"
  Given I am logged in as "skinner" with password "password"
  When I am on skin's new page
    And I fill in "Title" with "Default"
    And I fill in "CSS" with "#title { text-decoration: blink;}"
    And I press "Create"
  Then I should see "must be unique"
  When I fill in "Title" with "my blinking skin"
    And I press "Create"
  Then I should see "Skin was created successfully"
    And I should see "my blinking skin skin by skinner"
    And I should see "text-decoration: blink;"
  When I follow "skinner"
    And I follow "Preferences"
  Then "Default" should be selected within "preference_skin_id"
  When I select "Plain Text" from "preference_skin_id"
    And I select "my blinking skin" from "preference_skin_id"
    And I press "Update"
  Then "my blinking skin" should be selected within "preference_skin_id"
    And I should see "#title {" within "style"
    And I should see "text-decoration: blink;" within "style"
  When I am on the skins page
  Then I should not see "my blinking skin"
  When I follow "My Skins"
  Then I should see "my blinking skin"
    And I should see "(No Description Provided)"
    And I should not see "(Approved)"
    And I should not see "(Not yet reviewed)"
    And I should see "by skinner"
  When I follow "Edit"
    And I fill in "CSS" with "#greeting { text-decoration: blink;}"
    And I fill in "Title" with "public blinking skin"
    And I fill in "Description" with "Blinky love"
    And I check "skin_public"
    And I press "Update"
  Then I should see "Skin preview should be set for the skin to be public"
  When I attach the file "test/fixtures/skin_test_preview.png" to "skin_icon"
    And I press "Update"
  Then I should see "Skin updated"
    And I should not see "#title"
    And I should not see "my blinking"
    And I should see "Blinky love"
  When I am on the skins page
  Then I should not see "public blinking skin"
  When I follow "My Skins"
  Then I should see "public blinking skin"
    And I should see "(Not yet reviewed)"
    And I should not see "(Approved)"
  When I follow "skinner"
    And I follow "My Preferences"
  Then "public blinking skin" should be selected within "preference_skin_id"
    And I should see "text-decoration: blink;" within "style"
    And I should see "#greeting" within "style"
  Given I am logged out
  And I am on the skins page
  Then I should not see "public blinking skin"
    And I should not see "My Skins"
    And I should not see "Create New Skin"
    And I should not see "Change Your Skin"
  When I go to "public blinking skin" skin page
    Then I should see "Sorry, you don't have permission"
  When I am on skin's new page
    Then I should see "Sorry, you don't have permission"
  When I go to "public blinking skin" edit skin page
    Then I should see "Sorry, you don't have permission"
  When I go to admin's skins page
    Then I should see "I'm sorry, only an admin can"
  Given the following activated user exists
    | login    | password |
    | someuser | password |
    And I fill in "user_session_login" with "someuser"
    And I fill in "user_session_password" with "password"
    And I press "Log in"
  When I go to admin's skins page
  Then I should see "I'm sorry, only an admin can look at that area"
  When I go to "public blinking skin" skin page
  Then I should see "Sorry, you don't have permission"
    And I should not see "Edit"
  When I go to admin's skins page
    Then I should see "I'm sorry, only an admin can"
  Given I am logged out
    And I am logged in as an admin
  When I go to "public blinking skin" skin page
  Then I should not see "Edit"
  When I go to "public blinking skin" edit skin page
  Then I should see "Please log out of your admin account first"
  When I go to admin's skins page
    Then I should see "public blinking skin" within "table#unapproved"
  When I check "public blinking skin"
    And I press "Update"
  Then I should see "The following skins were approved: public blinking skin"
  When I follow "Approved Skins"
  Then I should see "public blinking skin" within "table#approved"
  Given I am logged out as an admin
    And I fill in "user_session_login" with "skinner"
    And I fill in "user_session_password" with "password"
    And I press "Log in"
  Then I should see "Hi, skinner!"
  When I go to "public blinking skin" edit skin page
  Then I should see "This skin can't be edited anymore!"
  When I follow "My Skins"
  Then I should see "(Approved)"
    And I should not see "Edit"
  When I follow "my home"
    And I follow "My Preferences"
  Then "public blinking skin" should be selected within "preference_skin_id"
  Given I am logged out
    And I am logged in as "someuser" with password "password"
  When I am on the skins page
    And I follow "someuser"
    And I follow "My Preferences"
    And I select "public blinking skin" from "preference_skin_id"
    And I press "Update"
  Then I should see "text-decoration: blink;" within "style"
  When I am logged out
    And I am logged in as an admin
  When I follow "skins"
    And I follow "Approved Skins"
    And I check "make_unofficial_public_blinking_skin"
    And I press "Update"
  Then I should see "The following skins were unapproved and removed from preferences: public blinking skin"
    And I should see "public blinking skin" within "table#unapproved"
  Given I am logged out as an admin
    And I am logged in as "skinner" with password "password"
  Then I should not see "text-decoration: blink;" within "style"
  When I am on skinner's skin page
  Then I should not see "(Approved)"
    And I should see "(Not yet reviewed)"
    And I should see "Edit"
  When I follow "skinner"
    And I follow "My Preferences"
  Then "Default" should be selected within "preference_skin_id"
  Given I am logged out
    And I am logged in as "someuser" with password "password"
  Then I should not see "text-decoration: blink;" within "style"
  When I am on the skins page
  Then I should not see "public blinking skin"
  When I follow "someuser"
    And I follow "My Preferences"
  Then "Default" should be selected within "preference_skin_id"
  And I should not see "public blinking skin"

  
  Scenario: Create skin using the wizard

  Given basic skins
  When I am on the skins page
  Then I should see "Default by AO3"
    And I should see "Plain Text by AO3"
  Given I am logged in as "skinner" with password "password"
  When I am on skin's new page
  Then I should see "CSS" within "dl"
  When I follow "Use Wizard Instead?"
  Then I should see "More options coming soon"
    And I should not see "CSS" within "dl"
  When I follow "Write Custom CSS Instead?"
  Then I should see "CSS" within "dl"
  When I follow "Use Wizard Instead?"
    And I fill in "Title" with "Wide margins"
    And I fill in "Description" with "Layout skin"
    And I fill in "skin_margin" with "text"
    And I press "Create"
  Then I should see "We couldn't save this Skin"
    And I should see "Margin is not a number"
  When I fill in "skin_margin" with "5"
    And I press "Create"
  Then I should see "Skin was created successfully"
    And I should see "Margin5"
  When I follow "Edit"
    And I follow "Use Wizard Instead?"
    And I fill in "skin_margin" with "4"
    And I fill in "skin_font" with "Garamond"
    And I fill in "skin_background_color" with "#ccccff"
    And I fill in "skin_foreground_color" with "red"
    And I fill in "skin_base_em" with "120"
    And I press "Update"
  Then I should see "Skin updated"
  When I follow "skinner"
    And I follow "My Preferences"
  Then "Default" should be selected within "preference_skin_id"
  When I select "Wide margins" from "preference_skin_id"
    And I press "Update"
  Then "Wide margins" should be selected within "preference_skin_id"
    And I should see "#chapters {margin: auto 4% 2.5em; padding: 0.5em 4% 0;}" within "style"
    And I should see "body {background: #ccccff; color: red; font: 120%/1.125 Garamond;}" within "style"
