Feature: Filing an abuse report
  In order to report something
  As an annoyed user
  I want to file an abuse ticket

  Scenario: File an abuse request with default options
  
  Given I have a work "Illegal thing"
  When I am logged in as "otheruser"
    And I am on the home page
    And I follow "Report Abuse"
  Then I should see "Most abuse reports fall into the following categories"
    And I should see the text with tags "value=\"http://www.example.com/"
  When I fill in "Describe your concern" with "This is wrong"
    And I fill in "Link to the page you are reporting" with "http://www.example.org/"
    And I press "Submit"
  # Redirecting to home means flash message doesn't show
  # Then I should see "Your abuse report was sent to the Abuse team."
  Then 1 email should be delivered
    And the email should contain "This is wrong"
  
  Scenario: URL is auto-filled on abuse report
  
  Given I have a work "Illegal thing"
  When I am logged in as "otheruser"
    And I view the work "Illegal thing"
    And I follow "Report Abuse"
  Then I should see the text with tags "value=\"http://www.example.com/works/"
  
  Scenario: Receive a copy of your abuse request
  
  Given I have a work "Illegal thing"
  When I am logged in as "otheruser"
    And I am on the home page
    And I follow "Report Abuse"
  When I select "Inappropriate content rating" from "Please select your concern"
    And I fill in "Describe your concern" with "This is wrong"
    And I fill in "Link to the page you are reporting" with "http://www.example.org/"
    And I check "Email me a copy of my message (optional)"
    # TODO: I believe the failure on the next step is a defect
  #  And I press "Submit"
  #Then I should see "Your abuse report was sent to the Abuse team."
  #  And 2 emails should be delivered
  
  Scenario: File an anonymous abuse request while logged in
  
  When I am logged in as "otheruser"
    And I am on the home page
    And I follow "Report Abuse"
  When I select "Inappropriate content rating" from "Please select your concern"
    And I fill in "Describe your concern" with "This is wrong"
    And I fill in "Link to the page you are reporting" with "http://www.example.org/"
    And I fill in "Your email" with ""
    And I press "Submit"
  # Redirecting to home means flash message doesn't show
  # Then I should see "Your abuse report was sent to the Abuse team."
    And 1 email should be delivered
    And the email should contain "This is wrong"
  
  Scenario: File an abuse request while logged out
  
  Given I have a work "Illegal thing"
  When I am logged out
    And I am on the home page
    And I follow "Report Abuse"
  Then I should see "Most abuse reports fall into the following categories"
  When I select "Inappropriate content rating" from "Please select your concern"
    And I fill in "Describe your concern" with "This is wrong"
    And I fill in "Link to the page you are reporting" with "http://www.example.org/"
    And I press "Submit"
  # Redirecting to home means flash message doesn't show
  # Then I should see "Your abuse report was sent to the Abuse team."
    And 1 email should be delivered
    And the email should contain "This is wrong"
  
  Scenario: File an anon request but accidentally tick the box to have a copy emailed
  
  When I am logged in as "otheruser"
    And I am on the home page
    And I follow "Report Abuse"
  When I select "Inappropriate content rating" from "Please select your concern"
    And I fill in "Describe your concern" with "This is wrong"
    And I fill in "Link to the page you are reporting" with "http://www.example.org/"
    And I fill in "Your email" with ""
    And I check "Email me a copy of my message (optional)"
    And I press "Submit"
  Then 1 email should be delivered
  Then I should see "Sorry, we can only send you a copy of your abuse report if you enter a valid email address"
    And I should see "Your abuse report was sent to the Abuse team."
    
  Scenario: File an anon request but accidentally tick the box to have a copy emailed, then try to send it again (issue 820)
  
  When I am logged in as "otheruser"
    And I am on the home page
    And I follow "Report Abuse"
  When I select "Inappropriate content rating" from "Please select your concern"
    And I fill in "Describe your concern" with "This is wrong"
    And I fill in "Link to the page you are reporting" with "http://www.example.org/"
    And I fill in "Your email" with ""
    And I check "Email me a copy of my message (optional)"
    And I press "Submit"
  When I select "Inappropriate content rating" from "Please select your concern"
    And I fill in "Describe your concern" with "This is wrong"
    And I fill in "Link to the page you are reporting" with "http://www.example.org/"
    And I fill in "Your email" with "valid@archiveofourown.org"
    And I check "Email me a copy of my message (optional)"
    # TODO: Fix Issue 820
   # And I press "Submit"
  #Then 1 email should be delivered
  #Then I should see "Your abuse report was sent to the Abuse team."
