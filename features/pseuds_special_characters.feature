@users
Feature: Pseuds

Scenario: creating pseud with special characters, exploring the people page

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
  When I fill in "Name" with "Alice"
    And I press "Create"
  Then I should see "Pseud was successfully created."
  When I follow "Edit Pseud"
  Then I should see "Alice"
    And I should not see "Àlice"
  When I follow "Back To Pseuds"
	  And I follow "people" within ".navigation"
  Then I should see "A" within ".pagination"
    And I should not see "À" within ".pagination"
	When I follow "A"
  Then I should see "Alice"
    And I should see "special character name"
    And I should not see "Àlice"
  When I follow "B"
  Then I should not see "Alice"
	
