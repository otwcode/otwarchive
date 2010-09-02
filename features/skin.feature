Feature: creating and editing skins

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
    And I should see "text-decoration: blink;" within "style"
  When I am on the skins page
  Then I should not see "my blinking skin"
  When I follow "My Skins"
  Then I should see "my blinking skin"
    And I should see "(No Description Provided)"
    And I should not see "(Approved)"
    And I should not see "(Not yet approved)"
    And I should see "by skinner"
  When I follow "Edit"
    And I fill in "CSS" with "#greeting { text-decoration: blink;}"
    And I fill in "Title" with "public blinking skin"
    And I fill in "Description" with "Blinky love"
    And I check "skin_public"
    And I press "Update"
  Then I should see "Skin updated"
    And I should not see "#title"
    And I should not see "my blinking"
    And I should see "Blinky love"
  When I am on the skins page
  Then I should not see "public blinking skin"
  When I follow "My Skins"
  Then I should see "public blinking skin"
    And I should see "(Not yet approved)"
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
  When I go to admin's approve_skins page
    Then I should see "I'm sorry, only an admin can"
  Given I am logged in as "someuser" with password "password"
    And I go to "public blinking skin" skin page
    Then I should see "Sorry, you don't have permission"
    And I should not see "Edit"
  When I go to admin's approve_skins page
    Then I should see "I'm sorry, only an admin can"
  Given I am logged out
    And I am logged in as an admin
  When I go to "public blinking skin" skin page
  Then I should not see "Edit"
  When I go to "public blinking skin" edit skin page
  Then I should see "Please log out of your admin account first"
  When I follow "skins"
    Then I should see "public blinking skin" within "table#unapproved"
  When I check "public blinking skin"
    And I press "Approve skins"
  Then I should see "Skins were approved."
    And I should see "Please note, this skin has no preview image. To fix this, unapprove it and then reapprove with a preview"
    And I should see "public blinking skin" within "table#approved"
  Given I am logged out as an admin
    And I am logged in as "skinner" with password "password"
  When I am on my skin page
  Then I should see "(Approved)"
    And I should not see "Edit"
    And I should see the "alt" text "No skin preview available"
  When I follow "skinner"
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
    And I check "public blinking skin"
    And I press "Unapprove skins"
  Then I should see "Skins were unapproved"
    And I should see "public blinking skin" within "table#unapproved"
  Given I am logged out as an admin
    And I am logged in as "skinner" with password "password"
  Then I should not see "text-decoration: blink;" within "style"
  When I am on my skin page
  Then I should not see "(Approved)"
    And I should see "(Not yet approved)"
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
  Then I should see "CSS"
  When I follow "Use Wizard Instead?"
  Then I should see "More options coming soon"
  When I follow "Write Custom CSS Instead?"
  Then I should see "CSS"
  When I follow "Use Wizard Instead?"
    And I fill in "Title" with "Wide margins"
    And I fill in "Description" with "Layout skin"
    And I fill in "skin_margin" with "text"
    And I press "Create"
  Then I should see "We couldn't save this skin"
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
