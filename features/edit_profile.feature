@users
Feature: Edit profile
  In order to have an archive full of users
  As a humble user
  I want to fill out my profile

	Scenario: View and edit profile
		Given I create a user named "editname" with password "password"
		And I am logged in as "editname" with password "password"
		Then I should see "Hi, editname!"
    And I should see "Log out"
		When I follow "editname"
    Then I should see "My Dashboard"
    And I should see "There are no works or bookmarks under this name yet"
    When I follow "Profile"
    Then I should see "About editname"
    When I follow "Edit my profile"
    Then I should see "Edit My Profile"
    When I fill in "Title" with "Test title thingy"
    And I fill in "Location" with "Alpha Centauri"
    And I fill in "About me" with "This is some text about me."
    And I press "Update"
    Then I should see "Your profile has been successfully updated"
    And I should see "I live in: Alpha Centauri"
    And I should see "This is some text about me."
    
  Scenario: Manage pseuds
    Given I create a user named "editpseuds" with password "password"
		And I am logged in as "editpseuds" with password "password"
		Then I should see "Hi, editpseuds!"
    And I should see "Log out"
		When I follow "editpseuds"
    Then I should see "My Dashboard"
    And I should see "There are no works or bookmarks under this name yet"
    When I follow "Profile"
    Then I should see "About editpseuds"
    When I follow "Manage my pseuds"
    Then I should see "Pseuds for editpseuds"
    And I should see "editpseuds"
    When I follow "New Pseud"
    Then I should see "New pseud"
    When I fill in "Name" with "My new name"
    And I fill in "Description" with "I wanted to add another name"
    And I press "Create"
    Then I should see "Pseud was successfully created."
    And I should see "My new name"
    And I should see "There are no works or bookmarks under this name yet."
    And I should not see "I wanted to add another name"
    When I follow "Back To Pseuds"
    Then I should see "editpseuds (editpseuds)"
    And I should see "My new name (editpseuds)"
    And I should see "I wanted to add another name"
    And I should see "Default Pseud"
    