Feature: Filing a support request
  In order to get help
  As a confused user
  I want to file a support request

  Scenario: Filing a support request
  
  Given I am logged in as "puzzled"
  When I follow "Support and Feedback"
  Then I should see "General/Other"
  When I select "Feedback/Suggestions" from "feedback_category"
    And I fill in "Brief summary" with "Just a brief note"
    And I fill in "Your comment" with "Men have their old boys' network, but we have the OTW. You guys rock!"
    And all emails have been delivered
    And I press "Send"
  Then I should see "Your message was sent to the archive team - thank you!"
    And 2 emails should be delivered
    And the email should contain "Hi! We're working really hard to reply to everyone, and we'll be with you as soon as we can."
    And the email should contain "In the meantime, please enjoy this automated response as a sign of our appreciation; your feedback is greatly valued, and will be reviewed by our volunteers as soon as possible."
    And the email should contain "Just a brief note"
  When I follow "Support and Feedback"
    And I fill in "Brief summary" with "you suck"
    And I fill in "Your comment" with "blah blah blah"
    And I fill in "Your email (optional)" with ""
    And all emails have been delivered
    And I press "Send"
  Then I should see "Your message was sent to the archive team - thank you!"
    And 1 email should be delivered
    And the email should contain "you suck"

  Scenario: Not logged in, with email
  
  When I am on the home page
    And I follow "Support and Feedback"
  Then I should see "General/Other"
  When I select "Feedback/Suggestions" from "feedback_category"
    And I fill in "Brief summary" with "Just a brief note"
    And I fill in "Your comment" with "Men have their old boys' network, but we have the OTW. You guys rock!"
    And I fill in "Your email (optional)" with "test@archiveofourown.org"
    And all emails have been delivered
    And I press "Send"
  Then I should see "Your message was sent to the archive team - thank you!"
    And 2 emails should be delivered
    
  Scenario: Not logged in, without email
  
  When I am on the home page
  When I follow "Support and Feedback"
    And I fill in "Brief summary" with "you suck"
    And I fill in "Your comment" with "blah blah blah"
    And I fill in "Your email (optional)" with ""
    And all emails have been delivered
    And I press "Send"
  Then I should see "Your message was sent to the archive team - thank you!"
    And 1 email should be delivered
    And the email should contain "you suck"
