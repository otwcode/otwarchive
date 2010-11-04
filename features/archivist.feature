@users @admin
Feature: Archivist bulk imports

  Scenario: Log in as an archivist and import a big archive.
    Given the following admin exists
      | login       | password |
      | EYalkut     | secret   |
      And the following activated user exists
      | login       | password      |
      | elynross    | Yulet1de      |
      And all emails have been delivered
    When I am logged in as "elynross" with password "Yulet1de"
      And I follow "Import"
    Then I should not see "Import works for others"
    When I follow "Log out"
      And I go to the admin_login page
      And I fill in "admin_session_login" with "EYalkut"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
      And I fill in "query" with "elynross"
      And I press "Find"
    Then I should see "elynross" within "#admin_users_table"
    When I check "user_archivist"
      And I press "Update"
    Then I should see "User was successfully updated"
    When I follow "Log out"
      And I am logged in as "elynross" with password "Yulet1de"
      And I follow "Import"
    Then I should see "Import works for others"
    When I check "Import works for others"
      And I fill in "urls" with
        """
        http://cesy.dreamwidth.org/154770.html
        http://cesy.dreamwidth.org/394320.html
        http://yuletidetreasure.org/archive/84/thatshall.html
        """
      And I check "Post without previewing"
      And I press "Import"
    Then I should see "Importing completed successfully for the following works! (But please check the results over carefully!)"
      And I should see "Imported Works"
      And I should see "We were able to successfully upload the following works."
      And I should see "Welcome"
      And I should see "OTW Meetup in London"
      And I should see "That Shall Achieve The Sword"
    When "notifying authors for imports" is fixed
      # And I should see "We have notified the author(s) you imported stories for. You can also add them as co-authors manually."
    # Given the system processes jobs
    # Then show me the emails
    # Then 1 email should be delivered to "shalott@intimations.org"
    #   And 1 email should be delivered to "cesy@dreamwidth.org"
