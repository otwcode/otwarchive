Feature: Filing an abuse report
  In order to report something
  As an annoyed user
  I want to file an abuse ticket

  Scenario: File an abuse request with default options

  Given basic languages
  When I am logged in as "otheruser"
    And I am on the home page
    And I follow "Policy Questions & Abuse Reports"
    And I should see the text with tags 'value="http://www.example.com/'
  When I fill in "Description of the content you are reporting (required)" with "This is wrong"
    And I fill in "Brief summary of Terms of Service violation (required)" with "This is a summary of bad things"
    And I fill in "Link to the page you are reporting (required)" with "http://www.archiveofourown.org/works"
    And I press "Submit"
  Then I should see "Your report was submitted to the Policy & Abuse team. A confirmation message has been sent to the email address you provided."
    # Receiving a copy of the abuse report is no longer a choice for the user.
    # The email is sent automatically.
    And 1 email should be delivered

  Scenario: URL is auto-filled on abuse report

  Given I have a work "Illegal thing"
    And basic languages
  When I am logged in as "otheruser"
    And I view the work "Illegal thing"
    And I follow "Policy Questions & Abuse Reports"
  Then I should see the text with tags 'value="http://www.example.com/works/'

  Scenario: File an abuse request while logged out

  Given basic languages
  When I am on the home page
    And I follow "Policy Questions & Abuse Reports"
  When I fill in "Brief summary of Terms of Service violation (required)" with "This is a summary of bad things"
    And I fill in "Description of the content you are reporting (required)" with "This is wrong"
    And I fill in "Link to the page you are reporting (required)" with "http://www.archiveofourown.org/works"
    And I fill in "Your email (required)" with "otheruser@example.org"
    And I press "Submit"
  Then I should see "Your report was submitted to the Policy & Abuse team. A confirmation message has been sent to the email address you provided."
    And 1 email should be delivered

  Scenario: File a request and enter blank email

  When I am logged in as "otheruser"
    And basic languages
    And I am on the home page
    And I follow "Policy Questions & Abuse Reports"
    And I fill in "Brief summary of Terms of Service violation (required)" with "This is a summary of bad things"
    And I fill in "Description of the content you are reporting (required)" with "This is wrong"
    And I fill in "Link to the page you are reporting (required)" with "http://www.archiveofourown.org/works"
    And I fill in "Your email (required)" with ""
    And I select "Deutsch" from "abuse_report_language"
    And I press "Submit"
    And I should see "Email should look like an email address."
    And "Deutsch" should be selected within "Select language (required)"
  Then I fill in "Your email (required)" with "valid@archiveofourown.org"
    And I press "Submit"
    And I should see "Your report was submitted to the Policy & Abuse team. A confirmation message has been sent to the email address you provided."
    And 1 email should be delivered

  Scenario: File a report containing images

  Given I am logged in as "otheruser"
    And basic languages
  When I follow "Policy Questions & Abuse Reports"
    And I fill in "Brief summary of Terms of Service violation (required)" with '<img src="foo.jpg" />Gross'
    And I fill in "Description of the content you are reporting (required)" with "This is wrong <img src='bar.jpeg' />"
    And I fill in "Link to the page you are reporting (required)" with "http://www.archiveofourown.org/works"
    And I press "Submit"
  Then 1 email should be delivered
    # The sanitizer adds the domain in front of relative image URLs as of AO3-6571
    And the email should not contain "<img src="http://www.example.org/foo.jpg" />"
    And the email should not contain "<img src="http://www.example.org/bar.jpeg" />"
    But the email should contain "Gross"
    And the email should contain "This is wrong http://www.example.org/bar.jpeg"
