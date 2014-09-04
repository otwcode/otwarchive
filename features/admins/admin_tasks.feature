@admin
Feature: Admin tasks
    
  Scenario: admin can find users
  
    Given I am logged in as "someone"
      And I have loaded the "roles" fixture
      When I am logged in as an admin
        And I fill in "query" with "someone"
        And I press "Find"
      Then I should see "someone" within "#admin_users_table"

  Scenario: Change some admin settings for performance - guest downloading and tag wrangling

    Given the following activated tag wrangler exists
        | login           |
        | dizmo           |
      And a character exists with name: "Ianto Jones", canonical: true

    # post a work and download it as a guest

    When I am logged in as "dizmo"
      And I post the work "Storytime"
      And I log out
      And I view the work "Storytime"
    Then I should see "Download"

    # turn off guest downloading

  When I am logged in as an admin
  When I follow "Settings"
  Then I should see "Turn off downloading for guests"
    And I should see "Turn off tag wrangling for non-admins"
  When I check "Turn off downloading for guests"
    And I press "Update"
  Then I should see "Archive settings were successfully updated."

    # Check guest downloading is off

    When I log out
    Then I should see "Successfully logged out"
    When I view the work "Storytime"
      And I follow "MOBI"
    Then I should see "Due to current high load"

    # Turn off tag wrangling

    When I am logged in as an admin
    When I follow "Settings"
      And I check "Turn off tag wrangling for non-admins"
      And I press "Update"
    Then I should see "Archive settings were successfully updated."

    # Check tag wrangling is off

    When I log out
    Then I should see "Successfully logged out"
    When I am logged in as "dizmo"
      And I edit the tag "Ianto Jones"
    Then I should see "Wrangling is disabled at the moment. Please check back later."
      And I should not see "Synonym of"

    # Set them back to normal
    Given I am logged out
    Given guest downloading is on
    Given I am logged out as an admin
    Given tag wrangling is on

  Scenario: admin goes to the Support page

  Given I am logged in as an admin
  When I go to the support page
  Then I should see "Support and Feedback"
    And I should see "testadmin@example.org" in the "feedback_email" input
