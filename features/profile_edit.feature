@users
Feature: Edit profile
  In order to have an archive full of users
  As a humble user
  I want to fill out my profile

  Scenario: View and edit profile - add details, edit details, remove details

  Given the following activated user exists
    | login         | password   |
    | editname      | password   |
    | othername     | password   |
	And I am logged in as "editname" with password "password"
  Then I should see "Hi, editname!"
  When I am on othername's user page
  Then I should see "There are no works or bookmarks under this name yet"
  When I follow "editname"
  Then I should see "My Dashboard"
    And I should see "You don't have anything posted under this name yet"
    And I should see "Would you like"
	When I am editing my profile
    And I fill in "Title" with "Test title thingy"
    And I fill in "Location" with "Alpha Centauri"
    And I fill in "About Me" with "This is some text about me."
    And I press "Update"
  Then I should see "Your profile has been successfully updated"
    And I should see "Alpha Centauri" within ".wrapper"
    And I should see "This is some text about me." within ".userstuff"
		And 0 emails should be delivered
  When I follow "Edit My Profile"
    And I fill in "Title" with "Alternative title thingy"
    And I fill in "Location" with "Beta Centauri"
    And I fill in "About Me" with "This is some <font color='red'>text</font> about me and my colours."
    And I press "Update"
  Then I should see "Your profile has been successfully updated"
    And I should see "Alternative title thingy"
    And I should see "Beta Centauri" within ".wrapper"
    And I should see "This is some text about me and my colours." within ".userstuff"
		And 0 emails should be delivered
  When I follow "Edit My Profile"
    And I fill in "Title" with ""
    And I fill in "Location" with ""
    And I fill in "About Me" with ""
    And I press "Update"
  Then I should see "Your profile has been successfully updated"
    And I should not see "Alternative title thingy"
    And I should not see "Beta Centauri" within ".wrapper"
    And I should not see "This is some text about me and my colours."
		And 0 emails should be delivered
		
Scenario: View and edit profile - email address - changing and displaying, and can't be the same as another user's
	
  Given the following activated users exist
    | login         | password   | email        |
    | editname     | password   | bar@ao3.org  |
    | duplicate     | password   | foo@ao3.org  |
    And I am logged in as "editname" with password "password"
    And all emails have been delivered
		And I follow "editname"
  When I am editing my profile
	  And I fill in "Change Email" with "blah"
    And I press "Update"
  Then I should see "You must authenticate"
	   And 0 emails should be delivered
		 And I should not see "successfully updated"
	When I enter an invalid email
  Then I should see "Email does not seem to be a valid address"
		And 0 emails should be delivered
		And I should not see "successfully updated"
  When I fill in "Change Email" with "valid2@archiveofourown.org"
    And I fill in "Old password" with "passw"
    And I press "Update"
  Then I should see "Your old password was incorrect"
	  And 0 emails should be delivered
		And I should not see "successfully updated"
	When I change my email
  Then I should see "Your email has been successfully updated"
    And 1 email should be delivered to "bar@ao3.org"
  When I follow "My Preferences"
    And I check "Display Email Address"
    And I press "Update"
    And I follow "editname"
		And I follow "Profile"
  Then I should see "My email address: valid2@archiveofourown.org"
  When I follow "Log out"
    And I am logged in as "duplicate" with password "password"
    And I follow "duplicate"
	When I enter a duplicate email
	Then I should see "Email has already been taken"
		
	Scenario: View and edit profile - date of birth - changing and displaying

  Given the following activated users exist
    | login         | password   |
    | editname     | password   |
    | duplicate     | password   |
    And I am logged in as "editname" with password "password"
    And I follow "editname"
  When I am editing my profile
	When I change my date of birth
  Then I should see "Your profile has been successfully updated"
  When I follow "My Preferences"
    And I check "Display Date of Birth"
	When I check my date of birth
  Then I should see "My birthday: 1980-12-31"
  When I follow "Edit My Profile"
    And I select "March" from "profile_attributes[date_of_birth(2i)]"
    And I press "Update"
  Then I should see "Your profile has been successfully updated"
    And I should see "My birthday: 1980-03-31"
		And 0 emails should be delivered
		
  Scenario: View and edit profile - change password

  Given I am logged in as "editname" with password "password"
		And I follow "editname"
	When I am editing my profile
		And I follow "Change My Password"
  When I fill in "New Password" with "newpass1"
    And I fill in "Confirm New Password" with "newpass1"
    And I fill in "Old password" with "wrong"
    And I press "Change Password"
  Then I should see "Your old password was incorrect"
  When I fill in "New Password" with "newpass1"
    And I fill in "Confirm New Password" with "newpass2"
    And I fill in "Old password" with "password"
    And I press "Change Password"
  Then I should see "Password doesn't match confirmation"
	When I change my password
  Then I should see "Your password has been changed"
		And 1 email should be delivered
  When I follow "Log out"
    And I fill in "User name" with "editname"
    And I fill in "Password" with "password"
    And I press "Log in"
  Then I should see "The password you entered doesn't match our records. Please try again or click the 'forgot password' link below."
  When I am logged in as "editname2" with password "newpass1"
  Then I should see "Hi, editname2"
	
	Scenario: Manage pseuds - add, edit

  Given the following activated user exists
    | login         | password   |
		| editpseuds    | password   |
    And I am logged in as "editpseuds" with password "password"
  Then I should see "Hi, editpseuds!"
    And I should see "Log out"
  When I follow "editpseuds"
  Then I should see "My Dashboard"
    And I should see "You don't have anything posted under this name yet"
  When I follow "Profile"
  Then I should see "About editpseuds"
  When I follow "Manage My Pseuds"
  Then I should see "Pseuds for editpseuds"
    And I should see "editpseuds"
	When I make a new pseud
  Then I should see "Pseud was successfully created."
    And I should see "My new name"
    And I should see "You don't have anything posted under this name yet."
    And I should not see "I wanted to add another name"
  When I follow "Back To Pseuds"
  Then I should see "editpseuds (editpseuds)"
    And I should see "My new name (editpseuds)"
    And I should see "I wanted to add another name"
    And I should see "Default Pseud"
  When I follow "editpseuds"
    And I follow "Profile"
    And I follow "Manage My Pseuds"
  Then I should see "Edit My new name"
  When I follow "edit_my_new_name"
    And I fill in "Description" with "I wanted to add another fancy name"
    And I fill in "Name" with "My new fancy name"
    And I press "Update"
  Then I should see "Pseud was successfully updated"
  When I follow "Back To Pseuds"
  Then I should see "editpseuds (editpseuds)"
    And I should see "My new fancy name (editpseuds)"
    And I should see "I wanted to add another fancy name"
    And I should not see "My new name (editpseuds)"
    And I should not see "I wanted to add another name"
