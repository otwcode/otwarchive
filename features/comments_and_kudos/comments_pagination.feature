@comments
Feature: Comments should be paginated

Scenario: One-chapter work with many comments
  Given the work with 34 comments setup
  When I view the work "Blabla"
    And I follow "Comments"
  Then I should see "2" within ".pagination"
  When I follow "Next" within ".pagination"
  Then I should see "1" within ".pagination"

# TODO
# Scenario: Multi-chapter work with many comments per chapter
