@users
Feature: Edit profile
  In order to have a presence on the archive
  As a humble user
  I want to fill out and edit my profile

Background: 
  Given the following activated user exists
	| login    | password   | email  	   |
	| editname | password   | bar@ao3.org  |	
  And I am logged in as "editname"
  And I want to edit my profile


Scenario: Edit profile - add details  
	
  When I fill in the details of my profile
    Then I should see "Your profile has been successfully updated"
	And 0 emails should be delivered
		
Scenario: Edit profile - change details 
	
  When I change the details in my profile
    Then I should see "Your profile has been successfully updated" 
	And 0 emails should be delivered
	
Scenario:	Edit profile - remove details

  When I remove details from my profile
    Then I should see "Your profile has been successfully updated"
    And 0 emails should be delivered
		
Scenario: Edit profile - changing email address requires reauthenticating

  When I follow "Email"
  And I fill in "New Email" with "blah"
  And I fill in "Confirm New Email" with "blah"
  And I press "Change Email"
    Then I should see "You must enter your password"
    And 0 emails should be delivered
		 
Scenario: Edit profile - changing email address - entering an invalid email address
		
  When I enter an invalid email
	Then I should see "Email does not seem to be a valid address"
	And 0 emails should be delivered
		
Scenario: Edit profile - changing email address - entering an incorrect password

  When I enter an incorrect password
    Then I should see "Your password was incorrect"
	And 0 emails should be delivered

Scenario: Edit profile - Changing email address and viewing 

  When I change my email
    Then I should see "Your email has been successfully updated"
	And 1 email should be delivered to "bar@ao3.org"
	When I change my preferences to display my email address
	  Then I should see "My email address: valid2@archiveofourown.org"

Scenario: Edit profile -  Changing email address -- can't be the same as another user's

  When I enter a duplicate email
	Then I should see "Email has already been taken"
	And 0 emails should be delivered
		
Scenario: Edit profile - date of birth - under age

  When I enter a birthdate that shows I am under age 
    Then I should see "You must be over 13"
	
Scenario: Edit profile - entering date of birth and displaying

  When I fill in my date of birth
    Then I should see "Your profile has been successfully updated"
    When I change my preferences to display my date of birth
      Then I should see "My birthday: 1980-11-30"
	  And 0 emails should be delivered
		
Scenario: Edit profile - change password - mistake in typing old password

  When I make a mistake typing my old password
    Then I should see "Your old password was incorrect"
	
Scenario: Edit profile - change password - mistake in typing new password confirmation
	
  When I make a typing mistake confirming my new password
    Then I should see "Password doesn't match confirmation"
	
Scenario: Edit profile - change password
 
  When I change my password
    Then I should see "Your password has been changed"
	And 0 emails should be delivered
	
