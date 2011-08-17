@users @admin @archivist_import
Feature: Archivist bulk imports

  Scenario: Non-archivist cannot import for others
  
  When I am logged in as a random user
    And I follow "Import"
  Then I should not see "Import works for others"
  
  Scenario: Make a user an archivist
  
  Given I am logged in as "elynross"
    And I have loaded the "roles" fixture
    When I am logged in as an admin
      And I fill in "query" with "elynross"
      And I press "Find"
    When I check "user_roles_4"
      And I press "Update"
    Then I should see "User was successfully updated"
    
  Scenario: Archivist can see link to import for others
  
  Given I have an archivist "elynross"
    When I am logged in as "elynross"
      And I follow "Import"
    Then I should see "Import works for others"

  Scenario: Import a single work as an archivist
  
  Given I have an archivist "elynross"
    When I am logged in as "elynross"
      And I follow "Import"
    When I check "Import works for others"
      And I fill in "urls" with 
      """
      http://cesy.dreamwidth.org/154770.html
      """
      And I check "Post without previewing"
      And I press "Import"
    Then I should not see "Importing completed successfully for the following works! (But please check the results over carefully!)"
      And I should not see "Imported Works"
      And I should not see "We were able to successfully upload the following works."
      And I should see "Welcome"
      And I should see "We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually."
      
  Scenario: Import multiple works as an archivist
  
  Given I have an archivist "elynross"
    When I am logged in as "elynross"
      And I follow "Import"
    When I check "Import works for others"
      And I fill in "urls" with 
      """
      http://cesy.dreamwidth.org/154770.html
      http://cesy.dreamwidth.org/394320.html
      """
      And I check "Post without previewing"
      And I press "Import"
    Then I should see "Importing completed successfully for the following works! (But please check the results over carefully!)"
      And I should see "Imported Works"
      And I should see "We were able to successfully upload the following works."
      And I should see "Welcome"
      And I should see "OTW Meetup in London"
      And I should see "We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually."
  
  Scenario: Importing sends an email with the right messages
  
  Given I have an archivist "elynross"
    When I am logged in as "elynross"
      And I follow "Import"
    When I check "Import works for others"
      And I fill in "urls" with "http://yuletidetreasure.org/archive/84/thatshall.html"
      And I check "Post without previewing"
      And I press "Import"
    Then I should see "We have notified the author(s) you imported stories for"
      And I should see "That Shall Achieve The Sword"
    Given the system processes jobs
    Then 1 email should be delivered to "shalott@intimations.org"
      And the email should contain invitation warnings
 
  Scenario: Importing only sends one email even if there are many works
  
    Given I have an archivist "elynross"
    When I am logged in as "elynross"
      And I follow "Import"
    When I check "Import works for others"
      And I fill in "urls" with
        """
        http://cesy.dreamwidth.org/154770.html
        http://cesy.dreamwidth.org/394320.html
        """
      And I check "Post without previewing"
      And I press "Import"
    Then I should see "Importing completed successfully for the following works! (But please check the results over carefully!)"
      And I should see "Imported Works"
      And I should see "We were able to successfully upload the following works."
      And I should see "Welcome"
      And I should see "OTW Meetup in London"
      And I should see "We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually."
    Given the system processes jobs
    Then 1 email should be delivered to "cesy@dreamwidth.org"

  Scenario: Importing doesn't send an email if you're already an author on the archive
  # TODO
