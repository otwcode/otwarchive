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
    And I submit
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

  Scenario: A user should be able to select one of their own non-public skins to use in their preferences
  Given I am logged in as "skinner"
    And I create the skin "my blinking skin" with css "#title { text-decoration: blink;}"
  When I am on skinner's preferences page
    And I select "my blinking skin" from "preference_skin_id"
    And I submit
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
    And I submit
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
    And I submit
  Then I should see an update confirmation message

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
  Then I should see "public skin" within "table#unapproved_skins"

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
    And I submit
  Then I should see "The following skins were updated: public skin"
  When I follow "Approved Skins"
  Then I should see "public skin" within "table#approved_skins"

  Scenario: Admins should be able to edit but not delete public approved skins
  Given the approved public skin "public skin" with css "#title { text-decoration: blink;}"
    And I am logged in as an admin
  When I go to "public skin" skin page
  Then I should see "Edit"
    But I should not find "Delete"
  When I follow "Edit"
    And I fill in "CSS" with "#greeting.logged-in { text-decoration: blink;}"
    And I fill in "Description" with "Blinky love (admin modified)"
    And I submit
  Then I should see an update confirmation message
    And I should see "(admin modified)"
    And I should see "#greeting.logged-in"
    And I should not see "#title"

  Scenario: Users should not be able to edit their public approved skins
  Given the approved public skin "public skin"
    And I am logged in as "skinner"
    And I go to "public skin" edit skin page
  Then I should see "Sorry, you don't have permission"
  When I follow "My Skins"
  Then I should see "(Approved)"
    And I should not see "Edit"

  Scenario: Users should be able to use public approved skins created by others
  Given the approved public skin "public skin" with css "#title { text-decoration: blink;}"
    And I am logged in as "skinuser"
    And I am on skinuser's preferences page
  When I select "public skin" from "preference_skin_id"
    And I submit
  Then I should see "Your preferences were successfully updated."
    And "public skin" should be selected within "preference_skin_id"
    And I should see "#title {" within "style"
    And I should see "text-decoration: blink;" within "style"

  Scenario: Admins should be able to unapprove public skins, which should also remove them from preferences
  Given "skinuser" is using the approved public skin "public skin" with css "#title { text-decoration: blink;}"
    And I unapprove the skin "public skin"
  Then I should see "The following skins were updated: public skin"
    And I should see "public skin" within "table#unapproved_skins"
  When I am logged in as "skinuser"
    And I am on skinuser's preferences page
  Then "Default" should be selected within "preference_skin_id"
    And I should not see "#title"
    And I should not see "text-decoration: blink;"

  Scenario: Users should be able to create a skin using the wizard
  Given basic skins
    And I am logged in as "skinner"
  When I am on skin's new page
  Then I should see "CSS" within "form#new_skin"
  When I follow "Use Wizard Instead?"
  Then I should see "Archive Skin Wizard"
    And I should not see "CSS" within "form"
  When I follow "Write Custom CSS Instead?"
  Then I should see "CSS"
  When I follow "Use Wizard Instead?"
    And I fill in "Title" with "Wide margins"
    And I fill in "Description" with "Layout skin"
    And I fill in "skin_margin" with "text"
    And I submit
  Then I should see a save error message
    And I should see "Margin is not a number"
  When I fill in "skin_margin" with "5"
    And I submit
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
    And I submit
    # TODO: Think about whether rounding to 4 is actually the right behaviour or not
  Then I should see an update confirmation message
    And I should see "4"
    And I should not see "4.5"
  When I am on skinner's preferences page
  Then "Default" should be selected within "preference_skin_id"
  When I select "Wide margins" from "preference_skin_id"
    And I submit
  Then I should see "Your preferences were successfully updated."
    And I should see "#workskin {margin: auto 4%; padding: 0.5em 4% 0;}" within "style"
    And I should see "background: #ccccff;" within "style"
    And I should see "color: red;" within "style"
    And I should see "font-family: Garamond;" within "style"
    And I should see "font-size: 120%;" within "style"
    And I should see "line-height:1.125;" within "style"
    And I should see ".userstuff p {margin-bottom: 5.0em;}" within "style"
  When I am on skinner's preferences page
  Then "Wide margins" should be selected within "preference_skin_id"

  Scenario: Users should be able to create and use a work skin
  Given I am logged in as "skinner"
  When I am on skin's new page
    And I select "Work Skin" from "skin_type"
    And I fill in "Title" with "Awesome Work Skin"
    And I fill in "Description" with "Great work skin"
    And I fill in "CSS" with "p {color: purple;}"
    And I submit
  Then I should see "Skin was successfully created"
    And I should see "#workskin p"
  When I go to the new work page
  Then I should see "Awesome Work Skin"
  When I set up the draft "Story With Awesome Skin"
    And I select "Awesome Work Skin" from "work_work_skin_id"
    And I press "Preview"
  Then I should see "Preview"
    And I should see "color: purple" within "style"
  When I press "Post"
  Then I should see "Story With Awesome Skin"
    And I should see "color: purple" within "style"
    And I should see "Hide Creator's Style"
  When I follow "Hide Creator's Style"
  Then I should see "Story With Awesome Skin"
    And I should not see "color: purple"
    And I should not see "Hide Creator's Style"
    And I should see "Show Creator's Style"

  Scenario: log out from my skins page (Issue 2271)
  Given I am logged in as "skinner"
    And I am on my user page
  When I follow "Skins"
    And I log out
  Then I should be on the login page

  Scenario: Change the header color
  Given I am logged in as "skinner"
  When I create a skin to change the header color
  Then I should see a different header color

  Scenario: Change the accent color
  Given I am logged in as "skinner"
  When I create a skin to change the accent color
  Then I should see a different accent color on the dashboard and work meta

  Scenario: Create a complex replacement skin
  Given I have loaded site skins
    And I am logged in as "skinner"
    And I set up the skin "Complex"
    And I select "replace archive skin entirely" from "skin_role"
    And I check "add_site_parents"
    And I submit
  Then I should see a create confirmation message
  When I check "add_site_parents"
    And I submit
  Then I should see errors

  Scenario: Vendor-prefixed properties should be allowed
    Given basic skins
      And I am logged in as "skinner"
    When I am on skin's new page
      And I fill in "Title" with "skin with prefixed property"
      And I fill in "CSS" with ".myclass { -moz-box-sizing: border-box; -webkit-transition: opacity 2s; }"
      And I submit
    Then I should see "Skin was successfully created"

  Scenario: #workskin selector prefixing
    Given basic skins
      And I am logged in as "skinner"
    When I am on skin's new page
      And I select "Work Skin" from "skin_type"
      And I fill in "Title" with "#worksin prefixing"
      And I fill in "CSS" with "#workskin, #workskin a, #workskin:hover, #workskin *, .prefixme, .prefixme:hover, * .prefixme { color: red; }"
      And I submit
    Then I should not see "#workskin #workskin,"
      And I should not see "#workskin #workskin a"
      And I should see ", #workskin a,"
      And I should not see "#workskin #workskin:hover"
      And I should see "#workskin .prefixme,"
      And I should see "#workskin .prefixme:hover"
      And I should see "#workskin * .prefixme"

  Scenario: New skin form should have the correct skin type pre-selected
    Given I am logged in as "skinner"
    When I am on the skins page
      And I follow "Create Skin"
    Then "Site Skin" should be selected within "skin_type"
    When I am on the skins page
      And I follow "Work Skins"
      And I follow "Create Skin"
    Then "Work Skin" should be selected within "skin_type"

  Scenario: Skin type should persist and remain selectable if you encounter errors during creation
    Given I am logged in as "skinner"
    When I am on the skins page
      And I follow "Work Skins"
      And I follow "Create Skin"
      And I fill in "Title" with "invalid skin"
      And I fill in "CSS" with "this is invalid css"
      And I submit
    Then I should see errors
      And "Work Skin" should be selected within "skin_type"
    When I select "Site Skin" from "skin_type"
      And I fill in "CSS" with "still invalid css"
      And I submit
    Then I should see errors
      And "Site Skin" should be selected within "skin_type"
