Feature: Fandom Relationship Tags Link

  Scenario: Click on "Relationships by Character" on a fandom tag containing periods  
    Given a canonical fandom "Harry Potter - J. K. Rowling"
    When I view the tag "Harry Potter - J. K. Rowling"
        And I follow "Relationship tags in this fandom" 
    Then I should not see "The page you were looking for doesn't exist."
        And I should see "Relationships by Character"