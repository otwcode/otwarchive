@users @admin @archivist_import
Feature: New Archivist bulk imports



  Scenario: Import a single work as an archivist specifying author

    Given I have an archivist "elynross"
    When I am logged in as "elynross"
    And I go to the import page
    When I check "Import for others ONLY with permission"
    And I fill in "urls" with
    """
      http://cesy.dreamwidth.org/154770.html
      """
    And I fill in "external_author_name" with
    """
     randomtestname
     """

    And I fill in "external_email_Address" with
    """
     otwstephanie@thepotionsmaster.net
     """

    And I check "Post without previewing"
    And I press "Import"
    Then I should not see multi-story import messages
    And I should see "Welcome"
    And I should see "We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually."

  Scenario: Import a single work as an archivist
  
  Given I have an archivist "elynross"
    When I am logged in as "elynross"
      And I go to the import page
    When I check "Import for others ONLY with permission"
      And I fill in "urls" with 
      """
      http://cesy.dreamwidth.org/154770.html
      """
      And I check "Post without previewing"
      And I press "Import"
    Then I should not see multi-story import messages
      And I should see "Welcome"
      And I should see "We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually."
      
