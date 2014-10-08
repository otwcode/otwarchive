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