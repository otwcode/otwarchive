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
    But I should see "Use"
    And I should see "Delete"
    And I should see "Edit"
    And I should not see "Stop Using"
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
  Then I should see "my blinking skin"
    And I should see "Use"
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
  When I am on skinner's skins page
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
  Then I should not see "Edit"
    And I should not see "Delete"
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
    But I should not see "Delete"
  When I follow "Edit"
    And I fill in "CSS" with "#greeting.logged-in { text-decoration: blink;}"
    And I fill in "Description" with "Blinky love (admin modified)"
    And I submit
  Then I should see an update confirmation message
    And I should see "(admin modified)"
    And I should see "#greeting.logged-in"
    And I should not see "#title"
  Then the cache of the skin on "public skin" should expire after I save the skin

  Scenario: Users should not be able to edit their public approved skins
  Given the approved public skin "public skin"
    And I am logged in as "skinner"
    And I go to "public skin" edit skin page
  Then I should see "Sorry, you don't have permission"
  When I am on the skins page
    Then I should see "public skin"
  When I follow "Site Skins"
  Then I should see "public skin"
    And I should see "(Approved)"
    And I should not see "Edit"

  Scenario: Users should be able to use public approved skins created by others
  Given the approved public skin "public skin" with css "#title { text-decoration: blink;}"
    And I am logged in as "skinuser"
    And I am on skinuser's preferences page
  When I select "public skin" from "preference_skin_id"
    And I submit
  Then I should see "Your preferences were successfully updated."
  When I am on skinuser's preferences page
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

  Scenario: User should be able to toggle between the wizard and the form
  When I am logged in
    And I am on skin's new page
  Then I should see "CSS" within "form#new_skin"
  When I follow "Use Wizard"
    Then I should see "Site Skin Wizard"
    And I should not see "CSS" within "form"
  When I follow "Write Custom CSS"
    Then I should see "CSS"

  Scenario: Users should be able to create and use a wizard skin to adjust work margins, and they should be able to edit the skin while they are using it
  Given I am logged in as "skinner"
  When I am on the new wizard skin page
    And I fill in "Title" with "Wide margins"
    And I fill in "Description" with "Layout skin"
    And I fill in "Work margin width" with "text"
    And I submit
  Then I should see a save error message
    And I should see "Margin is not a number"
  When I fill in "Work margin width" with "5"
    And I submit
  Then I should see "Skin was successfully created"
    And I should see "Work margin width: 5%"
  When I am on skinner's preferences page
  Then "Default" should be selected within "preference_skin_id"
  When I select "Wide margins" from "preference_skin_id"
    And I submit
  Then I should see "Your preferences were successfully updated."
    And I should see "margin: auto 5%; max-width: 100%" within "style"
  When I edit the skin "Wide margins" with the wizard
    And I fill in "Work margin width" with "4.5"
    And I submit
  # TODO: Think about whether rounding to 4 is actually the right behaviour or not
  Then I should see an update confirmation message
    And I should see "Work margin width: 4%"
    And I should not see "Work margin width: 4.5%"
    And I should see "margin: auto 4%;" within "style"
  When I am on skinner's preferences page
  Then "Wide margins" should be selected within "preference_skin_id"

  Scenario: Users should be able to create and use a wizard skin with multiple wizard settings
  Given I am logged in as "skinner"
  When I am on the new wizard skin page
    And I fill in "Title" with "Many changes"
    And I fill in "Description" with "Layout skin"
    And I fill in "Font" with "'Times New Roman', Garamond, serif"
    And I fill in "Background color" with "#ccccff"
    And I fill in "Text color" with "red"
    And I fill in "Percent of browser font size" with "120"
    And I fill in "Vertical gap between paragraphs" with "5"
    And I submit
  Then I should see "Skin was successfully created"
    And I should see "Font: 'Times New Roman', Garamond, serif"
    And I should see "Background color: #ccccff"
    And I should see "Text color: red"
    And I should see "Percent of browser font size: 120%"
    And I should see "Vertical gap between paragraphs: 5.0em"
  When I press "Use"
  Then I should see "Your preferences were successfully updated."
    And I should see "background: #ccccff;" within "style"
    And I should see "color: red;" within "style"
    And I should see "font-family: 'Times New Roman', Garamond, serif;" within "style"
    And I should see "font-size: 120%;" within "style"
    And I should see "margin: 5.0em auto;" within "style"
  When I am on skinner's preferences page
  Then "Many changes" should be selected within "preference_skin_id"

  Scenario: Users should be able to create and use a work skin
  Given I am logged in as "skinner"
    And the default ratings exist
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
  Then the cache of the skin on "Awesome Work Skin" should expire after I save the skin

  Scenario: log out from my skins page (Issue 2271)
  Given I am logged in as "skinner"
    And I am on my user page
  When I follow "Skins"
    And I log out
  Then I should be on the login page

  Scenario: Users should be able to adjust their wizard skin by adding custom CSS
  Given I am logged in as "skinner"
    And I create and use a skin to make the header pink
  When I edit my pink header skin to have a purple logo
  Then I should see an update confirmation message
    And I should see a pink header
    And I should see a purple logo

  Scenario: Change the accent color
  Given I am logged in as "skinner"
  When I create and use a skin to change the accent color
  Then I should see a different accent color

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
    Then the cache of the skin on "skin with prefixed property" should expire after I save the skin

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
      And I follow "Create Site Skin"
    Then "Site Skin" should be selected within "skin_type"
    When I am on the skins page
      And I follow "My Work Skins"
      And I follow "Create Work Skin"
    Then "Work Skin" should be selected within "skin_type"

  Scenario: Skin type should persist and remain selectable if you encounter errors during creation
    Given I am logged in as "skinner"
    When I am on the skins page
      And I follow "My Work Skins"
      And I follow "Create Work Skin"
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

  Scenario: View toggle buttons on skins (Issue 3197)
  Given basic skins
    And I am logged in as "skinner"
    When I am on skinner's preferences page
    When I follow "Skins"
  Then I should see "My Site Skins"
    And I should see "My Work Skins"
    And I should see "Public Site Skins"
    And I should see "Public Work Skins"

  Scenario: Toggle between user's work skins and site skins
  Given basic skins
    And I am logged in as "skinner"
    And I am on skinner's skins page
    And I follow "My Work Skins"
  Then I should see "My Work Skins"
    When I follow "My Site Skins"
  Then I should see "My Site Skins"

  Scenario: Toggle between public site skins and public work skins
  Given I am logged in as "skinner"
    And I am on skinner's skins page
    And I follow "Public Work Skins"
  Then I should see "Public Work Skins"
    When I follow "Public Site Skins"
  Then I should see "Public Site Skins"

  Scenario: Reverting to default skin when a custom skin is selected
  Given the approved public skin "public skin" with css "#title { text-decoration: blink;}"
    And I am logged in as "skinner"
    And I am on skinner's preferences page
    And I select "public skin" from "preference_skin_id"
    And I submit
  When I am on skinner's preferences page
    Then "public skin" should be selected within "preference_skin_id"
  When I go to skinner's skins page
    And I press "Revert to Default Skin"
  When I am on skinner's preferences page
    Then "Default" should be selected within "preference_skin_id"

  Scenario: The cache should be flushed with a parent and not when unrelated
  Given I have loaded site skins
    And I am logged in as "skinner"
    And I set up the skin "Complex"
    And I select "replace archive skin entirely" from "skin_role"
    And I check "add_site_parents"
    And I submit
  Then I should see a create confirmation message
  When I am on skin's new page
    And I fill in "Title" with "my blinking skin"
    And I fill in "CSS" with "#title { text-decoration: blink;}"
    And I submit
  Then I should see "Skin was successfully created"
  Then the cache of the skin on "my blinking skin" should not expire after I save "Complex"
  Then the cache of the skin on "Complex" should expire after I save a parent skin
  
  Scenario: Users should be able to create skins using @media queries
  Given I am logged in as "skinner"
    And I set up the skin "Media Query Test Skin"
    And I check "only screen and (max-width: 42em)"
    And I check "only screen and (max-width: 62em)"
  When I press "Submit"
  Then I should see a create confirmation message
    And I should see "only screen and (max-width: 42em), only screen and (max-width: 62em)"
  When I press "Use"
  Then the page should have a skin with the media query "only screen and (max-width: 42em), only screen and (max-width: 62em)"
