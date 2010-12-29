@users
Feature: Pseuds

Scenario: creating pseud with special characters

  Given I am logged in as "myself" with password "password"
    And I go to myself's user page
		And I follow "Profile" within ".navigation"
		And I follow "Manage My Pseuds" within ".navigation"
		And I follow "New Pseud" within ".navigation"
		And I fill in "Name" with "Àlice"
		And I fill in "Description" with "special character name"
		And I fill in "Icon alt text for screenreaders" with "special Alice"
		And I press "Create"
	Then I should see "We couldn't save this Pseud, sorry!" within ".error"
		And I should not see "Pseud was successfully created." 
  #Then I should see "Pseud was successfully created."
  #When I follow "Edit Pseud"
  #Then I should see "Àlice"
  #When I follow "Back To Pseuds"
	  #And I follow "People" within ".navigation"
	  #And I follow "A"
  #Then I should see "Àlice"
	
