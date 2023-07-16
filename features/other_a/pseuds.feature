@users
Feature: Pseuds

Scenario: pseud creation and playing with the default pseud

  Given I am logged in as "myself"
    And I go to myself's pseuds page

  # Check that you can't edit your default pseud.
  Then I should see "Default Pseud"
  When I follow "Edit"
  Then I should see "You cannot change the pseud that matches your user name."
    And the "Make this name default" checkbox should be checked and disabled

  # Make a new default pseud called "Me."
  When I follow "Back To Pseuds"
    And I follow "New Pseud"
    And I fill in "Name" with "Me"
    And I check "Make this name default"
    And I fill in "Description" with "Something's cute"
    And I press "Create"
  Then I should see "Pseud was successfully created."
    And I should be on myself's "Me" pseud page

  # Make sure the new "Me" pseud is the default.
  When I follow "Edit Pseud"
  Then I should see "Me"
    And the "Make this name default" checkbox should not be disabled
    And the "Make this name default" checkbox should be checked

  # Make sure the old "myself" pseud is no longer the default.
  When I follow "Back To Pseuds"
    And I follow "edit_myself"
  Then the "Make this name default" checkbox should not be checked
    And the "Make this name default" checkbox should not be disabled

  # Edit "Me" to remove it as your default pseud.
  When I follow "Back To Pseuds"
    And I follow "Me"
  Then I should be on myself's "Me" pseud page
  When I follow "Edit Pseud"
    And I uncheck "Make this name default"
    And I press "Update"
  Then I should see "Pseud was successfully updated."
    And I should be on myself's "Me" pseud page

  # Make sure "Me" is no longer the default pseud, but "myself" is.
  When I follow "Edit Pseud"
  Then the "Make this name default" checkbox should not be checked
  When I follow "Back To Pseuds"
    And I follow "edit_myself"
  Then the "Make this name default" checkbox should be checked and disabled

  # Test the pseud update path by making Me the default pseud once again.
  When I follow "Back To Pseuds"
    And I follow "Me"
    And I follow "Edit Pseud"
    And I check "Make this name default"
    And I press "Update"
  Then I should see "Pseud was successfully updated."
    And I should be on myself's "Me" pseud page
  When I follow "Edit Pseud"
  Then the "Make this name default" checkbox should be checked

Scenario: Manage pseuds - add, edit

  Given I am logged in as "editpseuds"

  # Check the Manage My Pseuds link in the profile works.
  When I go to editpseuds's user page
    And I follow "Profile"
    And I follow "Manage My Pseuds"
  Then I should see "Pseuds for editpseuds"

  # Make a new pseud.
  When I follow "New Pseud"
    And I fill in "Name" with "My new name"
    And I fill in "Description" with "I wanted to add another name"
    And I press "Create"
  Then I should be on editpseuds's "My new name" pseud page
    And I should see "Pseud was successfully created."
    And I should see "My new name"
    And I should see "You don't have anything posted under this name yet."

  # Check that all pseuds are listed on user's pseuds page.
  When I follow "Back To Pseuds"
  Then I should see "editpseuds (editpseuds)"
    And I should see "My new name (editpseuds)"
    And I should see "I wanted to add another name"
    And I should see "Default Pseud"

  # Try to create another pseud with the same name you already used.
  When I follow "New Pseud"
  Then I should see "New pseud"
  When I fill in "Name" with "My new name"
    And I press "Create"
  Then I should see "You already have a pseud with that name."

  # Recheck various links.
  When I follow "Back To Pseuds"
    And I follow "editpseuds"
    And I follow "Profile"
    And I follow "Manage My Pseuds"
  Then I should see "Edit My new name"

  # Edit your new pseud's name and description.
  When I follow "edit_my_new_name"
    And I fill in "Description" with "I wanted to add another fancy name"
    And I fill in "Name" with "My new fancy name"
    And I press "Update"
  Then I should see "Pseud was successfully updated."
    And I should be on editpseuds's "My new fancy name" pseud page

  # Check that the changes to your pseud show up on your pseuds page.
  When I follow "Back To Pseuds"
  Then I should see "editpseuds (editpseuds)"
    And I should see "My new fancy name (editpseuds)"
    And I should see "I wanted to add another fancy name"
    And I should not see "My new name (editpseuds)"

Scenario: Comments reflect pseud changes immediately

  Given the work "Interesting"
    And I am logged in as "myself"
    And I add the pseud "before"
  When I set up the comment "Wow!" on the work "Interesting"
    And I select "before" from "comment[pseud_id]"
    And I press "Comment"
    And I view the work "Interesting" with comments
  Then I should see "before (myself)" within ".comment h4.byline"

  When it is currently 1 second from now
    And I change the pseud "before" to "after"
    And I view the work "Interesting" with comments
  Then I should see "after (myself)" within ".comment h4.byline"
    And I should not see "before (myself)"

Scenario: Many pseuds

  Given there are 3 pseuds per page
    And "Zaphod" has the pseud "Slartibartfast"
    And "Zaphod" has the pseud "Agrajag"
    And "Zaphod" has the pseud "Betelgeuse"
    And I am logged in as "Zaphod"

  When I view my profile
  Then I should see "Zaphod" within "dl.meta"
    And I should see "Agrajag" within "dl.meta"
    And I should see "Betelgeuse" within "dl.meta"
    And I should not see "Slartibartfast" within "dl.meta"
    And I should see "1 more pseud" within "dl.meta"

  When I go to my user page
  Then I should see "Zaphod" within "ul.expandable"
    And I should see "Agrajag" within "ul.expandable"
    And I should see "Betelgeuse" within "ul.expandable"
    And I should not see "Slartibartfast" within "ul.expandable"
    And I should see "All Pseuds (4)" within "ul.expandable"

  When I go to my "Slartibartfast" pseud page
  Then I should see "Pseuds" within "li.pseud > a"
    And I should see "Slartibartfast" within "ul.expandable"

  When I go to my pseuds page
  Then I should not see "Zaphod (Zaphod)" within "ul.pseud.index"
    But I should see "Agrajag (Zaphod)" within "ul.pseud.index"
    And I should see "Betelgeuse (Zaphod)" within "ul.pseud.index"
    And I should see "Slartibartfast (Zaphod)" within "ul.pseud.index"
    And I should see "Next" within ".pagination"
  When I follow "Next" within ".pagination"
  Then I should see "Zaphod (Zaphod)" within "ul.pseud.index"

  When there are 10 pseuds per page
    And I view my profile
  Then I should see "Zaphod, Agrajag, Betelgeuse, and Slartibartfast" within "dl.meta"
