Feature: Favorite Tags
  In order to browse more efficiently
  As an archive user
  I should be able to list my favorite tags on my homepage

  Scenario: Favorite a tag and have it added to my homepage, and then unfavorite the tag and have it removed from my homepage
  
  Given a canonical fandom "Dallas (TV 2012)"
  When I am logged in as "bourbon" with password "andbranch"
    And I go to the homepage
  Then I should see "Find your favorites"
    And I should see "Browse fandoms by media or favorite some tags to have them listed here!"
  When I view the "Dallas (TV 2012)" works index
  Then I should see a "Favorite Tag" button
  When I press "Favorite Tag"
  Then I should see "You have successfully added Dallas (TV 2012) to your favorite tags."
  When I go to the homepage
  Then I should see "Dallas (TV 2012)"
  When I follow "Dallas (TV 2012)"
  Then I should see an "Unfavorite Tag" button
  When I press "Unfavorite Tag"
  Then I should see "You have successfully removed Dallas (TV 2012) from your favorite tags."
  When I go to the homepage
  Then I should not see "Dallas (TV 2012)"
