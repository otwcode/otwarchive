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