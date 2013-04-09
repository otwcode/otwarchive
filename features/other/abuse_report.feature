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
    And I fill in "Link to the page you are reporting" with "http://www.archiveofourown.org/works"
    And I press "Submit"
  # Redirecting to home means flash message doesn't show
 #Then I should see "Your abuse report was sent to the Abuse team."
    And 1 email should be delivered
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
    And I fill in "Link to the page you are reporting" with "http://www.archiveofourown.org/works"
    And I check "Email me a copy of my message (optional)"
    And I press "Submit"
  # Redirecting to home means flash message doesn't show
 # Then I should see "Your abuse report was sent to the Abuse team."
    And 1 email should be delivered to "otheruser"
    And 1 email should be delivered to "abuse@example.org"

  Scenario: File an anonymous abuse request while logged in

  When I am logged in as "otheruser"
    And I am on the home page
    And I follow "Report Abuse"
  When I select "Inappropriate content rating" from "Please select your concern"
    And I fill in "Describe your concern" with "This is wrong"
    And I fill in "Link to the page you are reporting" with "http://www.archiveofourown.org/works"
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
    And I fill in "Link to the page you are reporting" with "http://www.archiveofourown.org/works"
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
    And I fill in "Link to the page you are reporting" with "http://www.archiveofourown.org/works"
    And I fill in "Your email" with ""
    And I check "Email me a copy of my message (optional)"
    And I press "Submit"
  Then I should see "Email cannot be blank if requesting an emailed copy of the Abuse Report"
  When I uncheck "Email me a copy of my message (optional)"
    And I press "Submit"
  # Redirecting to home means flash message doesn't show
  # And I should see "Your abuse report was sent to the Abuse team."
    And 1 email should be delivered

  Scenario: File a request and tick the box to have a copy emailed but forget to enter email address

  When I am logged in as "otheruser"
    And I am on the home page
    And I follow "Report Abuse"
  When I select "Inappropriate content rating" from "Please select your concern"
    And I fill in "Describe your concern" with "This is wrong"
    And I fill in "Link to the page you are reporting" with "http://www.archiveofourown.org/works"
    And I fill in "Your email" with ""
    And I check "Email me a copy of my message (optional)"
    And I press "Submit"
    And I should see "Email cannot be blank if requesting an emailed copy of the Abuse Report"
  Then I fill in "Your email" with "valid@archiveofourown.org"
    And I press "Submit"
  # Redirecting to home means flash message doesn't show
  # And I should see "Your abuse report was sent to the Abuse team."
    And 2 email should be delivered

