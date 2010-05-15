@user
  Feature: Search Author
  In order to test search
  As a humble coder
  I have to use cucumber with thinking sphinx

  Scenario: Search users from universal search box
   Given I have loaded the fixtures
     And the Sphinx indexes are updated
   When I am on the homepage.
     And I fill in "site_search" with "testuser2"
     And I press "Search"
   Then I should see "1 Found"
   When I follow "Advanced search"
     Then I should be on the search page
     When I fill in "refine_text" with ""
       And I fill in "refine_author" with "testuser"
       And I press "Search"
   Then I should see "4 Found"
