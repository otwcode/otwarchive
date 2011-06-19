@users
Feature: General notice banner

Scenario: Banner is blank until admin sets it

  When I am on the home page
  Then I should not see "Hide this banner"
  When I am logged in as "newname"
  Then I should not see "Hide this banner"

Scenario: Admin can set banner

  When an admin sets a custom banner notice
    And I am logged in as "ordinaryuser"
  Then the banner notice for a logged-in user should be set to "Custom notice"

Scenario: User can turn off banner using words

  When an admin sets a custom banner notice
  When I am logged in as "newname"
  When I am on my user page
  When I follow "Hide this banner"
  Then I should not see "Custom notice words"

Scenario: User can turn off banner using X button

  When an admin sets a custom banner notice
  When I am logged in as "newname"
  When I am on my user page
  When I follow "Close-flash" within "#notice-banner .submit"
  #Cucumber apparently doesn't like Javascript
  #Then I should not see "Custom notice words"

Scenario: Banner stays off when logging out and in again
  
  When an admin sets a custom banner notice
  When I turn off the banner
  When I am logged out
    And I am logged in as "newname"
  Then I should not see "Custom notice words"
  When I am on newname's user page
  Then I should not see "Custom notice words"
  
Scenario: logged out user can also see banner
  
  When an admin sets a custom banner notice
  Then the banner notice for a logged-out user should be set to "Custom notice"
  
Scenario: logged out user hides banner using words

  When an admin sets a custom banner notice
  When I am logged out
  When I am on the works page
  When I follow "Hide this banner"
  Then I should not see "Custom notice words"
  
Scenario: logged out user hides banner using X

  When an admin sets a custom banner notice
  When I am logged out
  When I am on the works page
  When I follow "Close-flash" within "#notice-banner .submit"
  #Cucumber apparently doesn't like Javascript
  #Then I should not see "Custom notice words"
  
Scenario: User can turn off banner in preferences if they don't have Javascript

  When an admin sets a custom banner notice
  When I am logged in as "newname"
    And I go to my preferences page
  Then I should see "Turn off the general banner notice"
  When I check "Turn off the general banner notice"
    And I press "Update"
  Then I should not see "Custom notice words"
  
Scenario: Admin changes banner and new text shows

  When an admin sets a custom banner notice
  When an admin sets a different banner notice
  Then the banner notice for a logged-in user should be set to "Other words"
  
Scenario: If user has turned off banner and admin changes words, it comes back

  When an admin sets a custom banner notice
  When I turn off the banner
  When an admin sets a different banner notice
  Then the banner notice for a logged-in user should be set to "Other words"
