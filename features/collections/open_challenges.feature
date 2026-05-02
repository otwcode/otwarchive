@collections
Feature: Open Challenges
  In order to find challenges currently accepting sign-ups
  As a user
  I want to browse and filter open challenges

  # list_challenges

  # merged GE + PM list

  Scenario: Open challenges page shows both gift exchanges and prompt memes

    Given a set of open challenges for searching
    When I view open challenges
    Then I should see "Open GE"
    And I should see "Open PM"

  Scenario: Open challenges page includes challenges with no closing date

    Given a set of open challenges for searching
    When I view open challenges
    Then I should see "No Close PM"

  # filter form

  Scenario: Filter form appears on open challenges page

    Given a set of open challenges for searching
    When I view open challenges
    Then I should see "Sort and Filter"

  Scenario: Challenge type filter is shown on open challenges page

    Given a set of open challenges for searching
    When I view open challenges
    Then I should see "Collection Type"

  Scenario: No Challenge option is not available on open challenges filter

    Given a set of open challenges for searching
    When I view open challenges
    Then I should not see "No Challenge"

  Scenario: Sort options are not shown on open challenges filter

    Given a set of open challenges for searching
    When I view open challenges
    Then I should not see "Sort by"

  # filtering

  Scenario: Filter open challenges by gift exchange type

    Given a set of open challenges for searching
    When I view open challenges
      And I choose "Gift Exchange Challenge"
      And I press "Sort and Filter"
    Then I should see "Open GE"
    And I should see "Moderated GE"
    And I should not see "Open PM"
    And I should not see "No Close PM"

  Scenario: Filter open challenges by prompt meme type

  Given a set of open challenges for searching
    When I view open challenges
      And I choose "Prompt Meme Challenge"
      And I press "Sort and Filter"
    Then I should see "Open PM"
    And I should see "No Close PM"
    And I should not see "Open GE"

  Scenario: Filter open challenges by title

    Given a set of open challenges for searching
    When I view open challenges
      And I fill in "collection_search_title" with "Open GE"
      And I press "Sort and Filter"
    Then I should see "Open GE"
    And I should not see "Open PM"
    And I should not see "No Close PM"

  Scenario: Filter open challenges by tag

    Given a set of open challenges for searching
    When I view open challenges
      And I fill in "collection_search_tag" with "Some cool tag"
      And I press "Sort and Filter"
    Then I should see "Open GE"
      And I should not see "Open PM"
      And I should not see "No Close PM"

  Scenario: Filter open challenges by moderated

    Given a set of open challenges for searching
    When I view open challenges
      And I choose "collection_search_moderated_true"
      And I press "Sort and Filter"
    Then I should see "Moderated GE"
    And I should not see "Open GE"
    And I should not see "Open PM"

  Scenario: Filter open challenges by closed collection

    Given a set of open challenges for searching
    When I view open challenges
      And I choose "collection_search_closed_true"
      And I press "Sort and Filter"
    Then I should see "Closed Collection GE"
      And I should not see "Open GE"
      And I should not see "Open PM"

  Scenario: Filter open challenges by multifandom

    Given a set of open challenges for searching
    When I view open challenges
      And I choose "collection_search_multifandom_true"
      And I press "Sort and Filter"
    Then I should see "Multifandom GE"
      And I should not see "Open GE"
      And I should not see "Open PM"

  # list_ge_challenges

  Scenario: Open gift exchange challenges page shows only gift exchanges

    Given a set of open challenges for searching
    When I view open challenges
      And I follow "Gift Exchange Challenges"
    Then I should see "Open GE"
    And I should not see "Open PM"
    And I should not see "No Close PM"

  Scenario: Challenge type filter is not shown on gift exchange challenges page

    Given a set of open challenges for searching
    When I view open challenges
      And I follow "Gift Exchange Challenges"
    Then I should not see "Collection Type"

  # list_pm_challenges

  Scenario: Open prompt meme challenges page shows only prompt memes

    Given a set of open challenges for searching
    When I view open challenges
      And I follow "Prompt Meme Challenges"
    Then I should see "Open PM"
    And I should see "No Close PM"
    And I should not see "Open GE"

  Scenario: Challenge type filter is not shown on prompt meme challenges page

    Given a set of open challenges for searching
    When I view open challenges
      And I follow "Prompt Meme Challenges"
    Then I should not see "Collection Type"
