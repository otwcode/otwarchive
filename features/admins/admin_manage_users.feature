@admin
Feature: Admin Actions to manage users
	In order to manage user accounts
  As an an admin
  I want to be able to look up and edit individual users

  Scenario: Admin can update a user's email address and roles
    Given the following activated user exists
      | login       | password      |
      | dizmo       | wrangulator   |
      And I have loaded the "roles" fixture
    When I am logged in as an admin
      And I fill in "query" with "dizmo"
      And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"

    # change user email
    When I fill in "user_email" with "dizmo@fake.com"
      And I press "Update"
    Then the "user_email" field should contain "dizmo@fake.com"

    # Adding and removing roles
    When I check "user_roles_1"
      And I press "Update"
    # Then show me the html
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should be checked
    When I uncheck "user_roles_1"
      And I press "Update"
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should not be checked

  Scenario: A valid Fannish Next of Kin is added for a user
  Given the following activated users exist
      | login         | password   |
      | harrykim      | diesalot   |
      | libby          | stillalive   |  
    And I am logged in as an admin
  When I go to the abuse administration page for "harrykim"
    And I fill in "Fannish next of kin's username" with "libby"
    And I fill in "Fannish next of kin's email" with "testy@foo.com"
  When I press "Update"
  Then I should see "Fannish next of kin added."
  When I go to the manage users page
    And I fill in "Name or email" with "harrykim"
    And I press "Find"
  Then I should see "libby"
  When I follow "libby"
  Then I should be on libby's user page

  Scenario: An invalid Fannish Next of Kin username is added
  Given the fannish next of kin "libby" for the user "harrykim"
    And I am logged in as an admin
  When I go to the abuse administration page for "harrykim"
    And I fill in "Fannish next of kin's username" with "userididnotcreate"
    And I press "Update"
  Then I should see "Fannish next of kin user is invalid."

  Scenario: A blank Fannish Next of Kin username can't be added
  Given the fannish next of kin "libby" for the user "harrykim"
    And I am logged in as an admin
  When I go to the abuse administration page for "harrykim"
    And I fill in "Fannish next of kin's username" with ""
    And I press "Update"
  Then I should see "Fannish next of kin user is missing."

  Scenario: A blank Fannish Next of Kin email can't be added
  Given the fannish next of kin "libby" for the user "harrykim"
    And I am logged in as an admin
  When I go to the abuse administration page for "harrykim"
    And I fill in "Fannish next of kin's email" with ""
    And I press "Update"
  Then I should see "Fannish next of kin email is missing."

  Scenario: A Fannish Next of Kin is edited
  Given the fannish next of kin "libby" for the user "harrykim"
    And the user "newlibby" exists and is activated
    And I am logged in as an admin
  When I go to the abuse administration page for "harrykim"
    And I fill in "Fannish next of kin's username" with "newlibby"
    And I fill in "Fannish next of kin's email" with "newlibby@foo.com"
    And I press "Update"
  Then I should see "Fannish next of kin user updated."
    And I should see "Fannish next of kin email updated."

  Scenario: A Fannish Next of Kin is removed
  Given the fannish next of kin "libby" for the user "harrykim"
    And I am logged in as an admin
  When I go to the abuse administration page for "harrykim"
    And I fill in "Fannish next of kin's username" with ""
    And I fill in "Fannish next of kin's email" with ""
    And I press "Update"
  Then I should see "Fannish next of kin removed."

  Scenario: A Fannish Next of Kin updates when the next of kin user changes their username
  Given the fannish next of kin "libby" for the user "harrykim"
    And I am logged in as "libby"
  When I visit the change username page for libby
    And I fill in "New User Name" with "newlibby"
    And I fill in "Password" with "password"
    And I press "Change User Name"
  Then I should get confirmation that I changed my username
  When I am logged in as an admin
    And I go to the manage users page
    And I fill in "Name or email" with "harrykim"
    And I press "Find"
  Then I should see "newlibby"

  Scenario: A Fannish Next of Kin stays with the user when the user changes their username
  Given the fannish next of kin "libby" for the user "harrykim"
    And I am logged in as "harrykim"
  When I visit the change username page for harrykim
    And I fill in "New User Name" with "harrykim2"
    And I fill in "Password" with "password"
    And I press "Change User Name"
  Then I should get confirmation that I changed my username
  When I am logged in as an admin
    And I go to the manage users page
    And I fill in "Name or email" with "harrykim2"
    And I press "Find"
  Then I should see "libby"

  Scenario: A Fannish Next of Kin can update even after an invalid user is entered
  Given the fannish next of kin "libby" for the user "harrykim"
    And the user "harrysmom" exists and is activated
    And I am logged in as an admin
  When I go to the abuse administration page for "harrykim"
    And I fill in "Fannish next of kin's username" with "libbylibby"
    And I fill in "Fannish next of kin's email" with "libbylibby@example.com"
    And I press "Update"
  Then I should see "Fannish next of kin user is invalid."
  When I fill in "Fannish next of kin's username" with "harrysmom"
    And I fill in "Fannish next of kin's email" with "harrysmom@example.com"
    And I press "Update"
  Then I should see "Fannish next of kin user updated."
    And the "Fannish next of kin's username" field should contain "harrysmom"
    And the "Fannish next of kin's email" field should contain "harrysmom@example.com"

  Scenario: A user is given a warning with a note
  Given the user "mrparis" exists and is activated
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Record warning"
    And I fill in "Notes" with "Next time, the brig."
  When I press "Update"
  Then I should see "Warning was recorded."
    And I should see "Warned"
    And I should see "Next time, the brig."

  Scenario: A user cannot be given a warning without a note
  Given the user "mrparis" exists and is activated
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Record warning"
  When I press "Update"
  Then I should see "You must include notes in order to perform this action."

  Scenario: A user is given a suspension with a note and number of days
  Given the user "mrparis" exists and is activated
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Suspend: enter a whole number of days"
    And I fill in "suspend_days" with "30"
    And I fill in "Notes" with "Disobeyed orders."
  When I press "Update"
  Then I should see "User has been temporarily suspended."
    And I should see "Suspended until"
    And I should see "Disobeyed orders."

  Scenario: A user cannot be given a suspension with without a number of days
  Given the user "mrparis" exists and is activated
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Suspend: enter a whole number of days"
    And I fill in "Notes" with "Disobeyed orders."
  When I press "Update"
  Then I should see "Please enter the number of days for which the user should be suspended."

  Scenario: A user cannot be given a suspension with without a note
  Given the user "mrparis" exists and is activated
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Suspend: enter a whole number of days"
    And I fill in "suspend_days" with "30"
  When I press "Update"
  Then I should see "You must include notes in order to perform this action."

  Scenario: A user is banned with a note
  Given the user "mrparis" exists and is activated
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Suspend permanently (ban user)"
    And I fill in "Notes" with "To the New Zealand penal colony with you."
  When I press "Update"
  Then I should see "User has been permanently suspended."
    And I should see "Suspended Permanently"
    And I should see "To the New Zealand penal colony with you."

  Scenario: A user cannot be banned without a note
  Given the user "mrparis" exists and is activated
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Suspend permanently (ban user)"
  When I press "Update"
  Then I should see "You must include notes in order to perform this action."

  Scenario: A user's suspension is lifted with a note
  Given the user "mrparis" is suspended
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Lift temporary suspension, effective immediately."
    And I fill in "Notes" with "Good behavior."
  When I press "Update"
  Then I should see "Suspension has been lifted."
    And I should see "Suspension Lifted"
    And I should see "Good behavior."

  Scenario: A user's suspension cannot be lifted without a note
  Given the user "mrparis" is suspended
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Lift temporary suspension, effective immediately."
  When I press "Update"
  Then I should see "You must include notes in order to perform this action."

  Scenario: A user's ban is lifted with a note
  Given the user "mrparis" is banned
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Lift permanent suspension, effective immediately."
    And I fill in "Notes" with "Need him to infiltrate the Maquis."
  When I press "Update"
  Then I should see "Suspension has been lifted."
    And I should see "Suspension Lifted"
    And I should see "Need him to infiltrate the Maquis."

  Scenario: A user's ban cannot be lifted without a note
  Given the user "mrparis" is banned
    And I am logged in as an admin
  When I go to the abuse administration page for "mrparis"
    And I choose "Lift permanent suspension, effective immediately."
  When I press "Update"
  Then I should see "You must include notes in order to perform this action."
