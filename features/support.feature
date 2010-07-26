Feature: Filing a support request
  In order to get help
  As a confused user
  I want to file a support request

  Scenario: Filing a support request
    Given the following activated user exists
    | login         | password   |
    | puzzled      | password   |
    And I am logged in as "puzzled" with password "password"
  When I follow "Support and Feedback"
  Then I should see "Please select a category:"
  When I select "Feedback/Suggestions" from "category"
    And I fill in "Brief summary" with "Just a brief note"
    And I fill in "Your comment" with "Men have their old boys' network, but we have the OTW. You guys rock!"
    And all emails have been delivered
    And I press "Send feedback"
  Then 2 emails should be delivered
  And I should see "Your message was sent to the archive team - thank you!"



